request = require 'request'
cheerio = require 'cheerio'
module.exports ?= {}

parseGrades = ($, $page) ->

  text_extract = ($elem) ->
    $elem.text()
      .replace /^[\n\s\t]*/, ''
      .replace /[\n\s\t]*$/, ''

  process_header_row = ($row) ->
    # TODO: Regex out the fluff
    return {
      name: text_extract $row.elemAt 'td', 0
      term: text_extract $row.elemAt 'td', 1
      submission: text_extract $row.elemAt 'td', 2
      level: text_extract $row.elemAt 'td', 3
      exercises: []
    }

  process_grade_row = ($row) ->
    return {
      id:           parseInt(text_extract $row.elemAt('td',  0))
      type:         text_extract  $row.elemAt  'td',  1
      title:        text_extract  $row.elemAt  'td',  2
      set_by:       text_extract  $row.elemAt  'td',  3
      declaration:  text_extract  $row.elemAt  'td',  4
      extension:    text_extract  $row.elemAt  'td',  5
      submission:   text_extract  $row.elemAt  'td',  6
      grade:        text_extract  $row.elemAt  'td',  7
    }

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
          modules.push current_module
        else
          current_module.exercises.push process_grade_row $row_elem
    return modules

  $subs_tbl = $page.elemAt('table', 7).find('table')

  # TODO: Regex extract useful values
  subscription_last_updated  =  text_extract  $subs_tbl.elemAt('td',  1)
  submissions_completed      =  text_extract  $subs_tbl.elemAt('td',  4)
  submissions_extended       =  text_extract  $subs_tbl.elemAt('td',  6)
  submissions_late           =  text_extract  $subs_tbl.elemAt('td',  8)

  required_modules = extract_modules $page.elemAt 'table', 9
  optional_modules = extract_modules $page.elemAt 'table', -2

  return {
    stats:
      subscription_last_updated: subscription_last_updated
      submissions_completed: submissions_completed
      submissions_extended: submissions_extended
      submissions_late: submissions_late
    required_modules: required_modules
    optional_modules: optional_modules
  }

# GET /api/grades
exports.getGrades = (req, res) ->
  options =
    url:  'https://cate.doc.ic.ac.uk/student.cgi?key=2013:c2:lmj112'
    auth: req.creds
  request options, (err, data, body) ->
    $ = cheerio.load body, {
      xmlMode: true
      lowerCaseTags:true
    }
    res.json parseGrades $, $ 'body'


