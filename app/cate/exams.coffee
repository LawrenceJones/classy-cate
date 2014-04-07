$ = require 'cheerio'
request = require 'request'
$q = require 'q'
config = require '../config'
CateResource = require './resource'
mongoose = require 'mongoose'
Exam = mongoose.model 'Exam'
MyExams = require './my_exams'

Array::addUnique = (elem, eq = ((a,b) -> a == b)) ->
  found = false
  found |= eq _elem, elem for _elem in @
  @push elem if not found

DOMAIN = 'https://exams.doc.ic.ac.uk'
EXPIRY = 10 * 60 * 60 * 1000

# Produces an array of the year anchor links.
getYearAnchors = ($uls) ->
  $li = $($uls[2]).find 'li'
  $anchors = ($(li).find 'a' for li in $li)

# Pull out the links to each of the past paper years.
extractYearLinks = ($page) ->
  anchors = getYearAnchors $page.find('ul') || []
  anchors.map (a) ->
    year: $(a).text()
    url: $(a).attr 'href'
    deferred: $q.defer()

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
      linkUrl = "#{DOMAIN}/#{link.url}"
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
        console.log exams
        if err?
          res.send 500
        else
          res.json exams
    else
      config.exams_timestamp = Date.now()
      auth = @createAuth req
      jquerify = @jquerify
      options = { url: @url(req), auth: auth}
      request options, (err, data, body) =>
        $page = jquerify(body)('body')
        links = extractYearLinks $page
        done = @getAllLinkPages links, auth
        done.then (years) =>
          cate_res = new self $page, years
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

