$q = require 'q'
jsdom = require 'jsdom'
jquery = require 'jquery'

# Base class for all CATe parsers. The general usage pattern
# is: initialise the parser with the html src url, the query
# parameters that were used to generate it and a jQuery handle
# that has parsed the source html.
# Following this, calling the extract method will return pure
# JSON data, extracted from the html source.
#
# User credentials are NOT handled here.
module.exports = class CateParser

  @CATE_PARSER:  true
  @CATE_DOMAIN:  'https://cate.doc.ic.ac.uk'
  @EXAM_DOMAIN:  'https://exams.doc.ic.ac.uk'
  @DBC_DOMAIN:   'https://dbc.doc.ic.ac.uk'
  @TEACH_DOMAIN: 'https://teachdb.doc.ic.ac.uk'

  # Sets parsing values.
  constructor: (@url, @query, @$) ->

  # Creates new jsdom environment, then returns a promise that
  # is resolved with the data generated by the parser instance.
  @parse: (url, query, html) ->
    $ = jquery(window = jsdom.jsdom().createWindow())
    $('html').html html
    parser = new @ url, query, $
    data = parser.extract $
    parser = $ = null
    return data

  # Helper to strip text.
  @textExtract: ($elem) ->
    $elem.text().replace /(^[\n\s\t]*)|([\n\s\t]*$)/g, ''

  # Generates the current cate academic year.
  @defaultYear: ->
    y = (d = new Date()).getFullYear()
    --y if d.getMonth() < 8 # September
    y

  # Extracts the module ID and name from a standard CATe resource
  # page. These include notes and givens.
  @extractModule: ($) ->

    # Find the module ID, ie. 202
    [moduleID, moduleName] = [null, null]
    $('center h3').each ->
      matched = $(@).text().match?(/Module (\d+): (.*)/)
      [moduleID, moduleName] = matched?[1..2] || []
      !(moduleID and moduleName)

    # If we can't identify a module ID then throw
    if !moduleID?
      throw error: code: 404, msg: 'Module not found'
    [moduleID, moduleName]



