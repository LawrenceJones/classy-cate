$ = require 'cheerio'
CateResource = require './resource'

# Helper to strip text.
text_extract = ($elem) ->
  $elem.text()
    .replace /(^[\n\s\t]*)|([\n\s\t]*$)/, ''

# Extracts header info.
process_header_row = ($row) ->
  if $row.find('td').length < 4 then return
  if (name = text_extract $row.elemAt 'td', 0).trim() == '' then return
  # TODO: Regex out the fluff
  name: name
  term: text_extract $row.elemAt 'td', 1
  submission: text_extract $row.elemAt 'td', 2
  level: text_extract $row.elemAt 'td', 3
  exercises: []

# Extracts submission details from jQuery $row.
process_grade_row = ($row) ->
  if (name = $row.elemAt('td', 2).text().trim()) == '' then return
  id:           parseInt(text_extract $row.elemAt('td',  0))
  type:         text_extract  $row.elemAt  'td',  1
  title:        text_extract  $row.elemAt  'td',  2
  set_by:       text_extract  $row.elemAt  'td',  3
  declaration:  text_extract  $row.elemAt  'td',  4
  extension:    text_extract  $row.elemAt  'td',  5
  submission:   text_extract  $row.elemAt  'td',  6
  grade:        text_extract  $row.elemAt  'td',  7

# Extracts grades from the given jQuery $table object.
extract_modules = ($table) ->

  $grade_rows = $ ($table.find('tr').slice 2)

  modules = []
  current_module = null
  $grade_rows.each (i, e) ->
    $row_elem = $(e)
    tds = $row_elem.find('td')
    if tds.length > 1 # Ignore spacer/empty rows
      if $(tds[0]).attr('colspan')
        current_module = process_header_row $row_elem
        modules.push current_module if current_module?
      else
        ex = process_grade_row $row_elem
        current_module.exercises.push ex if ex?
  return modules.filter (m) -> m.exercises.length > 0

module.exports = class Grades extends CateResource

  getRequired: ->
    extract_modules @$page.elemAt 'table', 9

  getOptional: ->
    extract_modules @$page.elemAt 'table', -2

  parse: ->

    $subs_tbl = @$page.elemAt('table', 7).find('table')

    # TODO: Regex extract useful values
    subscription_last_updated  =  text_extract  $subs_tbl.elemAt('td',  1)
    submissions_completed      =  text_extract  $subs_tbl.elemAt('td',  4)
    submissions_extended       =  text_extract  $subs_tbl.elemAt('td',  6)
    submissions_late           =  text_extract  $subs_tbl.elemAt('td',  8)

    @data = {
      stats:
        subscription_last_updated: subscription_last_updated
        submissions_completed: submissions_completed
        submissions_extended: submissions_extended
        submissions_late: submissions_late
      required_modules: @getRequired()
      optional_modules: @getOptional()
    }

  @url: ->
    'https://cate.doc.ic.ac.uk/student.cgi?key=2013:c2:lmj112'

