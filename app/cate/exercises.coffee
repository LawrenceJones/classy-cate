CateResource = require './resource'
config = require '../config'
$ = require 'cheerio'

# Hook for db access to CateModules
mongoose = require 'mongoose'
CateModule = mongoose.model 'CateModule'

# Base domain
DOMAIN = 'https://cate.doc.ic.ac.uk'

# Returns the current Cate based year. This means anything
# past christmas is rounded down one year.
currentYear = ->
  d = new Date()
  year = d.getFullYear()
  if d.getMonth() < 8 # September
    year--
  return year

# Converts a CATE style date into a JS Date object
# e.g. '2013-1-7' -> Mon Jan 07 2013 00:00:00 GMT+0000 (GMT)
parse_date = (input) ->
  [year, month, day] = input.match(/(\d+)/g)
  new Date(year, month - 1, day) # JS months index from 0

# Converts a month into an int (indexed from 1)
# e.g. "January" -> 1
# month - Month name as a capitalised string
month_to_int = (m) ->
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
            'August', 'September', 'October', 'November', 'December']
  return 6 if m == 'J'
  rexp = new RegExp(m,'g')
  for month,i in months
    if rexp.test(month) then return i+1

# Extracts months from table row
# e.g. ["January", "February", "March"]
# $tr - The Timetable table row jQuery Object
extract_months = ($tr) ->
  headers = ($(cell) for cell in $tr.find('th'))
  $month_cells = ($ c for c in headers when $(c).attr('bgcolor') == "white")
  month_names = (c.text().replace(/\s+/g, '') for c in $month_cells)
  month_ids = month_names.map month_to_int
  return month_ids

# Extracts days from table row
# e.g. ["1", "2", "3"]
# $tr - The Timetable table row jQuery Object
extract_days = ($tr) ->
  $th = ($(cell) for cell in $tr.find('th'))
  days_text = (c.text() for c in $th)
  valid_days = (d for d in days_text when d.replace(/\s+/g, '') != '')
  valid_days.map (d) -> parseFloat d, 10

# Extracts module details from a cell jQuery object
process_module_cell = ($cell) ->
  [id, name] = $cell.text().split(' - ')
  return {
    id : id
    name : name.replace(/^\s+|\s+$/g, '')
    notesLink : $cell.find('a').eq(0).attr('href')
  }

process_exercise_cell = ($ex_cell, current_date, colSpan) ->

  # Extracts both id and type of exercise, returns [id, type]
  extract_id_type = ->
    $ex_cell # [id, type]
      .elemAt('b', 0)
      .text().split(':')

  # Extracts the links
  extract_hrefs = ->
    links = {}
    rexs =
      mailto:  /mailto/i
      spec:    /SPECS/i
      givens:  /given/i
      handin:  /handins/i
    $ex_cell
      .find('a')
      .toArray()
      .reduce ((a,c) ->
        $c = $ c; if $c.attr('href')? then a.push $c.attr 'href'; a), []
      .map (href) ->
        for own k,rex of rexs
          links[k] ?= if rex.test href then href else null
    return links

  [id, type] = extract_id_type $ex_cell
  hrefs = extract_hrefs()

  name = $ex_cell
    .text()[(id.length + type.length + 2)..]
    .replace(/[\s\n\r\b]*$/, '')
  end = new Date(current_date.getTime())
  end.setDate(end.getDate() + colSpan - 1)

  id: id, type: type, name: name
  start: new Date(current_date.getTime()), end: end
  mailto: hrefs.mailto, spec: hrefs.spec
  givens: hrefs.givens, handin: hrefs.handin


# Add the parsed exercises to the given module
# module - the module to attach the exercises to
# exercise_cells - An array of cells (jQuery objects)
process_exercise_cells = ($cells, module_name, dates) ->

  if not $cells? then return null
  exercises = []

  current_date = parse_date dates.start
  current_date.setDate(current_date.getDate() - dates.colBufferToFirst)

  for ex_cell in $cells
    $ex_cell = $ ex_cell

    colSpan = parseInt($ex_cell.attr('colspan') ? 1)
    colSpan = 1 if colSpan == NaN

    if $ex_cell.attr('bgcolor')? and $ex_cell.find('a').length != 0
      ex = process_exercise_cell $ex_cell, current_date, colSpan
      ex.moduleName = module_name
      exercises.push ex

    current_date.setDate (current_date.getDate() + colSpan)

  return exercises.sort (a,b) ->
    if a.start < b.start then -1 else 1

module.exports = class Exercises extends CateResource

  # Extracts the table containing exercises
  getTimetable: ->
    ($ tb for tb in @$page.find('table') when $(tb).attr('border') == "0")[0]

  # Extracts full title e.g. Spring Term 2012-2013
  getTermTitle: ->
    title = @$page
      .elemAt('tr', 0)
      .elemAt('h1', 0)
      .text()

  # Extracts the academic years applicable
  # e.g. "Easter Period 2012-2013" -> ["2012", "2013"]
  getAcademicYears: ->
    years = @$page
      .find('h1')
      .text()[-9..]
      .split('-')

  getStartEndDates: ->

    $timetable = @getTimetable()
    years = @getAcademicYears()

    # TODO: What if the timetable crosses year boundaries?
    #       e.g over new year/christmas?
    [first_month, others..., last_month] =
      extract_months $timetable.elemAt('tr', 0)

    year = if first_month < 9 then years[1] else years[0]

    day_headers = $timetable
      .elemAt('tr', 2)
      .find('th')

    col_buf = 0
    col_buf += 1 while $(day_headers[col_buf]).is(":empty")

    [first_day, others..., last_day] =
      extract_days $timetable.find('tr').eq(2)

    return {  # remember _day in yyyy-mm-dd format
      start: year + '-' + first_month + '-' + first_day
      end: year + '-' + last_month + '-' + last_day
      colBufferToFirst: col_buf - 1
    }

  getModules: (dates) ->

    $timetable = @getTimetable()

    # Returns whether or not an element is a module container
    # $elem - jQuery element
    is_module = ($elem) ->
      $elem.find('font').attr('color') == "blue"

    allRows = $timetable.find('tr')
    modules = []
    count = 0
    while count < allRows.length
      current_row = allRows[count]
      following_row_count = 0
      module_elem = $($(current_row).find('td').eq(1))
      if is_module(module_elem)
        module_data = process_module_cell module_elem

        following_row_count = $(current_row)
          .elemAt('td', 0)
          .attr('rowspan') - 1
        following_rows = allRows[count+1..count+following_row_count]

        $ex_cells = ($(row).find('td')[1..] for row in following_rows)
        $ex_cells.push($(current_row).find('td')[4..])
        $ex_cells = (cs for cs in $ex_cells when cs?)

        ex_chunks = $ex_cells.map (cells) ->
          process_exercise_cells cells, module_data.name, dates
        module_data.exercises = [].concat ex_chunks...
        modules.push module_data
      count += following_row_count + 1
    return modules

  parse: ->
    dates = @getStartEndDates()   # WRONG
    modules = @getModules dates
    regged = CateModule.register modules, @req # IMPORTANT
    regged.then (data) -> console.log 'DONE'
    regged.catch (err) -> console.log err
    @data =
      year: @req.params.year
      period: @req.params.period
      start: dates.start, end: dates.end
      modules: @getModules dates
      term_title: @getTermTitle()

  @url: (req) ->
    [period, klass, year, user] = [
      req.query.period || config.cate.cached_period
      req.query.klass
      req.query.year   || currentYear()
      req.user.user
    ]
    [
      "#{DOMAIN}/timetable.cgi"
      "?period=#{period}"
      "&class=#{klass}"
      "&keyt=#{year}"
      "%3Anone%3Anone%3A"
      "#{user}"
    ].join ''

