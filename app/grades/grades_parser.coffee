CateParser = require '../cate/parser'
textExtract = CateParser.textExtract

# Extracts header info.
processHeaderRow = ($row) ->
  if $row.find('td').length < 4 then return
  if (name = textExtract $row.find 'td:eq(0)') == '' then return
  # TODO: Regex out the fluff
  name:        name
  exercises:   []
  term:        textExtract  $row.find  'td:eq(1)'
  submission:  textExtract  $row.find  'td:eq(2)'
  level:       textExtract  $row.find  'td:eq(3)'

# Extracts submission details from jQuery $row.
processGradeRow = ($row) ->
  if (name = $row.find('td:eq(2)').text().trim()) == '' then return
  id:  parseInt textExtract  $row.find 'td:eq(0)'
  type:         textExtract  $row.find 'td:eq(1)'
  title:        textExtract  $row.find 'td:eq(2)'
  set_by:       textExtract  $row.find 'td:eq(3)'
  declaration:  textExtract  $row.find 'td:eq(4)'
  extension:    textExtract  $row.find 'td:eq(5)'
  submission:   textExtract  $row.find 'td:eq(6)'
  grade:        textExtract  $row.find 'td:eq(7)'

# Extracts grades from the given jQuery $table object.
extractModules = ($, $table) ->

  modules = []
  currentModule = null
  $gradeRows = $table.find('tr')[2..]

  $gradeRows.each (i, e) ->
    $row = $ e
    if $row.find('td').length > 1 # Ignore spacer/empty rows
      if $row.find('td:eq(0)').attr('colspan')?
        currentModule = processHeaderRow $row
        modules.push currentModule if currentModule?
      else
        ex = processGradeRow $row
        currentModule.exercises.push ex if ex?

  return modules.filter (m) -> m.exercises.length > 0

# Parses the Grades page of CATe.
# Accepts data from ~/student.cgi?key=<YEAR>:<CLASS>:<USER>
module.exports = class GradesParser extends CateParser

  # Extracts the grades data using the $ handle.
  extract: ($) ->

    $subsTbl = $ 'table:eq(7) table'

    stats:
      subscription_last_updated:  textExtract  $subsTbl.find 'td:eq(1)'
      submissions_completed:      textExtract  $subsTbl.find 'td:eq(4)'
      submissions_extended:       textExtract  $subsTbl.find 'td:eq(6)'
      submissions_late:           textExtract  $subsTbl.find 'td:eq(8)'
    required_modules: extractModules $, $ 'table:eq(9)'
    optional_modules: extractModules $, $ 'table:eq(-2)'

  @url: (query) ->
    klass = query.klass
    user  = query.user
    year  = query.year  ||  @defaultYear()
    if not (klass && user && year)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/student.cgi?key=#{year}:#{klass}:#{user}"

