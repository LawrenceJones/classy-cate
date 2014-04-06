$ = require 'cheerio'
request = require 'request'
$q = require 'q'
config = require '../config'
CateResource = require './resource'
mongoose = require 'mongoose'
Exam = mongoose.model 'Exam'
MyExams = require './my_exams'

DOMAIN = 'https://exams.doc.ic.ac.uk'

getYearUl = ($uls) ->
  $($uls[2]).find('a').toArray()

# Pull out the links to each of the past paper years.
extractYearLinks = ($page) ->
  anchors = getYearUl $page.find('ul') || []
  anchors.map (a) ->
    year: $(a).text()
    url: $(a).attr 'href'
    deferred: $q.defer()

module.exports = class CateExam extends CateResource

  parse: ->
    @data =
      exams: @getTimetable()

  # Overrides the default getter, needed for specific
  # exams.doc.ic.ac.uk access.
  @get: (req, res) ->
    auth = @createAuth req
    jquerify = @jquerify
    options =
      url: @url req
      auth: auth
    request options, (err, data, body) =>
      $page = jquerify(body)('body')
      links = extractYearLinks $page
      done = $q.all links.map (link) ->
        deferred = link.deferred
        options =
          url: "#{DOMAIN}/#{link.url}"
          auth: auth
        request options, (err, data, body) ->
          deferred.resolve
            year: link.year
            $page: jquerify(body)
        return deferred.promise
      done.then (years) =>
        cate_res = new @ $page, years
        res.json cate_res.data

  @getMyExams: ->
    MyExams.get.apply MyExams, arguments

  @url: (req) ->
    DOMAIN # contains base links

