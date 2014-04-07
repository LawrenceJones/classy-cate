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

# Base domain and exam expiry rate.
DOMAIN = 'https://exams.doc.ic.ac.uk'
EXPIRY = 24 * 60 * 60 * 1000 # 24 hours

# The earliest year to be parsed from the archives.
EARLIEST_ARCHIVE = 1999

# Allows pushing to an array if element is not already present.
Array::addUnique = (elem, eq = ((a,b) -> a == b)) ->
  found = false
  found |= eq _elem, elem for _elem in @
  @push elem if not found

# Produces an array of the year anchor links.
getYearAnchors = ($uls) ->
  $li = $($uls[2]).find 'li'
  $anchors = ($(li).find 'a' for li in $li)

# Generates simple link object for an archive collection.
makeLink = (year) ->
  year: "#{year}-#{year + 1}"
  url: CateExam.yearUrl year
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

module.exports = class CateExam extends CateResource

  # Given a paper repo page, a year string, url to the
  # initial page and the exams shared object, it extracts
  # the relevant data.
  extractPapers: ($page, year, url, exams) ->
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

  # Given exam data, updates the internal database to reflect
  # any changes that may have occured.
  # TODO - Ensure update, rather than replace.
  updateDb: (exams) ->
    promises = Object.keys(exams).map (k, i) ->
      deferred = $q.defer()
      model = new Exam(exam = exams[k])
      model.save (err) ->
        if err? then deferred.reject err
        else deferred.resolve model
      return deferred.promise
    $q.all promises

  # Default extry parsing function.
  parse: ($page, years) ->
    exams = new Object()
    @extractPapers y.$page, y.year, y.url, exams for y in years.reverse()
    @dbUpdated = @updateDb exams

  # Generates a promise that is resolved with the jquerified
  # html from each link repository page.
  @getAllLinkPages: (links, auth) ->
    jquerify = @jquerify
    promises = links.map (link) ->
      deferred = link.deferred
      linkUrl = link.url
      options = { url: linkUrl, auth: auth }
      request options, (err, data, body) ->
        deferred.resolve
          year: link.year
          url: linkUrl
          $page: jquerify(body)('body')
      return deferred.promise
    return $q.all promises

  # Returns true if the cache requires updating.
  @cacheExpired: ->
    ts = config.exams_timestamp
    !ts? || ((Date.now() - ts) > EXPIRY)

  # Overrides the default getter, needed for specific
  # exams.doc.ic.ac.uk access.
  # This resource caches data about all the exams in the
  # database. Every EXPIRY milliseconds, any request made
  # to the server will update it's cache against exams.doc.
  @get: (req, res) ->
    self = this
    if !@cacheExpired()
      console.log 'Fetching db'
      Exam.find {}, (err, exams) ->
        if err? then res.send 500
        else
          res.json exams
    else
      config.exams_timestamp = Date.now()
      auth = @createAuth req
      jquerify = @jquerify
      options = { url: @url(req), auth: auth}
      request options, (err, data, body) =>
        $page = jquerify(body)('body')
        links = extractYearLinks $page, true # get archive too
        done = @getAllLinkPages links, auth
        done.then (years) =>
          cate_res = new self req, $page, years
          cate_res.dbUpdated
            .then -> self.get req, res
            .catch (err) ->
              console.error err
              res.send 500

  # Fetches the exams that the student is timetabled for.
  @getMyExams: ->
    MyExams.get.apply MyExams, arguments

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
