$ = require 'cheerio'
request = require 'request'
$q = require 'q'
mongoose = require 'mongoose'
config = require '../config'

# Cate resources
CateResource = require './resource'
MyExams = require './my_exams'

# Mongoose models
Exam = mongoose.model 'Exam'
CateModule = mongoose.model 'CateModule'
Upload = mongoose.model 'Upload'

# Base domain and exam expiry rate.
DOMAIN = 'https://exams.doc.ic.ac.uk'
EXPIRY = 24 * 60 * 60 * 1000 # 24 hours

# The earliest year to be parsed from the archives.
EARLIEST_ARCHIVE = 1999

# Produces an array of the year anchor links.
getYearAnchors = ($uls) ->
  $li = $($uls[2]).find 'li'
  $anchors = ($(li).find 'a' for li in $li)

# Generates simple link object for an archive collection.
makeLink = (year) ->
  year: "#{year}-#{year + 1}"
  url: CateExams.yearUrl year
  deferred: $q.defer()

# Parses the numerical year from the label. '2011-2012' -> 2011.
parseYear = (label) ->
  parseInt label.match(/^(\d+)-/)[1], 10

# Sorts links by their age.
sortLinks = (links) ->
  links.sort (a,b) -> parseYear(a.year) - parseYear(b.year)

# Pull out the links to each of the past paper years.
extractYearLinks = ($page, includeArchives) ->
  anchors = getYearAnchors $page.find('ul') || []
  links = anchors
    .map (a) ->
      year: $(a).text()
      url: "#{DOMAIN}/#{(a).attr 'href'}"
      deferred: $q.defer()
  if includeArchives
    endOfArchives = parseYear links[0].year
    y = EARLIEST_ARCHIVE - 1
    while ++y < endOfArchives
      links.unshift makeLink y
  sortLinks links

# Given a paper repo page, a year string, url to the
# initial page and the exams shared object, it extracts
# the relevant data.
extractPapers = ($page, year, url, exams) ->
  groups = new Object()
  $node = $page.children().eq(0)
  while $node.length > 0 && !/By class/.test $node.html()
    $node = $node.next()
  currentClass = null
  while ($node = $node.next()).length > 0 && !/^Complete/.test $node.text()
    if $node.is 'h3'
      currentClass = $node.text()
    else
      $a = $node.find 'a'
      if $a.length > 0
        [id, title] = $a.text().split ': '
        exam = (exams[id] ?= {})
        exam.id = id
        (exam.titles ?= []).addUnique title
        (exam.papers ?= []).addUnique {
          year: year
          url: "#{url}/#{$a.attr 'href'}"
        }, (a,b) -> a.year == b.year
        (exam.classes ?= []).push currentClass

# Generates a promise that is resolved with the jquerified
# html from each link repository page.
getAllLinkPages = (links, auth) ->
  promises = links.map (link) ->
    deferred = link.deferred
    linkUrl = link.url
    options = { url: linkUrl, auth: auth }
    request options, (err, data, body) ->
      deferred.resolve
        year: link.year
        url: linkUrl
        $page: CateResource.jquerify(body)('body')
    return deferred.promise
  return $q.all promises

# Returns all exams from the database.
getAllFromDb = (deferred = $q.defer()) ->
  console.log 'Fetching db'
  query = Exam
    .find {}
    .populate 'studentUploads'
  query.exec (err, exams) ->
    if err? then deferred.reject 500
    else
      deferred.resolve exams
  return deferred.promise

# Given exam data, updates the internal database to reflect
# any changes that may have occured.
# TODO - Ensure update, rather than replace.
updateDb = (exams) ->
  promises = Object.keys(exams).map (k, i) ->
    deferred = $q.defer()
    findOne = Exam.findOne {id: exams[k].id}
    findOne.exec (err, exam) ->
      if exam? then for p in exams[k].papers
        exam.papers.addUnique p, (a,b) -> a.url == b.url
      else exam = new Exam exams[k]
      exam.save (err) ->
        if err? then deferred.reject err
        else deferred.resolve exam
    return deferred.promise
  $q.all promises

# Retrives cate modules that may be associated with the given
# exam id. Looks for id matches against the numerical part of
# the exam id. Exam ID C210, will match against 210 for example.
getAssociatedModules = (id = '') ->
  ids = id.match /(\d+)/g
  return [] if ids.length is 0
  rex = "^#{ids.join('|')}$"
  deferred = $q.defer()
  CateModule.find { id: $regex:rex }, (err, modules) ->
    if err? then deferred.reject err
    else deferred.resolve modules
  deferred.promise

# Module for parsing exam data from exams.doc.ic.ac.uk.
# Caches all data into the mongodb Exams model.
module.exports = class CateExams extends CateResource

  # Default extry parsing function.
  parse: ($page, years) ->
    exams = new Object()
    extractPapers y.$page, y.year, y.url, exams for y in years.reverse()
    @dbUpdated = updateDb exams

  # Returns true if the cache requires updating.
  @cacheExpired: ->
    ts = config.exams_timestamp
    !ts? || ((Date.now() - ts) > EXPIRY)

  # Scrapes all exams by scraping exams.doc.
  @scrapeAll: (req, deferred = $q.defer()) ->
    config.exams_timestamp = Date.now()
    auth = CateResource.createAuth req
    options = { url: @url(req), auth: auth}
    request options, (err, data, body) =>
      $page = @jquerify(body)('body')
      links = extractYearLinks $page, true # get archive too
      done = getAllLinkPages links, auth
      done.then (years) =>
        cate_res = new CateExams req, $page, years
        cate_res.dbUpdated
          .then -> getAllFromDb deferred
    deferred.promise

  # Indexes all the exams, regardless of whether a student
  # is taking them.
  # exams.doc.ic.ac.uk access.
  # This resource caches data about all the exams in the
  # database. Every EXPIRY milliseconds, any request made
  # to the server will update it's cache against exams.doc.
  @index: (req, res) ->
    fetched = (deferred = $q.defer()).promise
    if !@cacheExpired()
      getAllFromDb deferred
    else
      @scrapeAll req, deferred
    fetched.then (exams) ->
      res.json exams
    fetched.catch (err) ->
      console.error "Fetching Exam data failed: #{err}"
      res.send 500

  # Pushed data into the associated modules and uploads fields.
  @populate: (req, exam) ->
    deferred = $q.defer()
    modules = getAssociatedModules exam.id
    modules.then (assoc) =>
      exam.related = assoc
      query = Upload.find {exam: exam._id}
      query.exec (err, uploads) =>
        if err? then return deferred.reject err
        else
          exam.studentUploads =
            uploads.map (u) -> u.mask req
          deferred.resolve exam
    modules.catch (err) ->
      console.error err
      res.send 500
    deferred.promise

  # GET /exams/:id
  # Receives an id parameter and returns the exam info from
  # the database table. If cache has expired will update table
  # first.
  @get: (req, res) ->
    query = Exam
      .findOne {id: req.params.id}
    query.exec (err, exam) =>
      if err? then res.send 500
      else
        fetched = @populate req, exam
        fetched.then (exam) ->
          res.json exam
        fetched.catch (err) ->
          console.error err
          res.send 500

  # Fetches the exams that the student is timetabled for.
  @getMyExams: ->
    MyExams.get.apply MyExams, arguments

  # Basic url for exams.doc.
  @url: (req) ->
    DOMAIN # contains base links

  # URL of the page indexing the paper archives
  @archiveUrl: ->
    "#{DOMAIN}/archive.html"

  # Generates the url for a specific years set of papers.
  @yearUrl: (year) ->
    y = parseInt year, 10
    key = [y, y+1]
      .map (c) -> c.toString().slice -2
      .join '-'
    url = "#{DOMAIN}/pastpapers/papers.#{key}"
