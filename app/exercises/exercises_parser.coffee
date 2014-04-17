CateParser = require '../cate/cate_parser'

# Converts a CATE style date into a JS Date object
# e.g. '2013-1-7' -> Mon Jan 07 2013 00:00:00 GMT+0000 (GMT)
parseDate = (input) ->
  [year, month, day] = input.match(/(\d+)/g)
  new Date(year, month - 1, day) # JS months index from 0

# Converts a month into an int (indexed from 1)
# e.g. "January" -> 1
# month - Month name as a capitalised string
monthToInt = (m) ->
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
            'August', 'September', 'October', 'November', 'December']
  return 6 if m == 'J'
  rexp = new RegExp(m,'g')
  for month,i in months
    if rexp.test(month) then return i+1

# Extracts months from table row
# e.g. ["January", "February", "March"]
# $tr - The Timetable table row jQuery Object
extractMonths = ($, $tr) ->
  $monthCells = $tr.find 'th[bgcolor="white"]'
  #$monthCells = ($ c for c in $headers when $(c).attr('bgcolor') == "white")
  $monthCells.map ->
    monthToInt $(this).text().replace /\s+/g, ''

# Extracts days from table row
# e.g. ["1", "2", "3"]
# $tr - The Timetable table row jQuery Object
extractDays = ($, $tr) ->
  daysText = $tr.find('th').map -> $(this).text()
  (parseFloat d, 10 for d in daysText\
                    when d.replace(/\s+/g, '') != '')

# Extracts module details from a cell jQuery object
processModuleCell = ($cell) ->
  [id, name] = $cell.text().split(' - ')
  id: id
  name: name.replace(/^\s+|\s+$/g, '')
  notesLink: $cell.find('a').eq(0).attr('href')

# Parses an exercise from the given cell
processExerciseCell = ($, $exCell, currentDate, colSpan) ->

  # Extracts both id and type of exercise, returns [id, type]
  extractIdType = ->
    $exCell # [id, type]
      .find 'b:eq(0)'
      .text().split(':')

  # Extracts the links
  extractHrefs = ->
    links = {}
    rexs =
      mailto:  /mailto/i
      spec:    /SPECS/i
      givens:  /given/i
      handin:  /handins/i
    $exCell
      .find('a')
      .toArray()
      .reduce ((a,c) ->
        $c = $ c; if $c.attr('href')? then a.push $c.attr 'href'; a), []
      .map (href) ->
        for own k,rex of rexs
          links[k] ?= if rex.test href then href else null
    return links

  [id, type] = extractIdType $exCell
  hrefs = extractHrefs()

  name = $exCell
    .text()[(id.length + type.length + 2)..]
    .replace(/[\s\n\r\b]*$/, '')
  end = new Date(currentDate.getTime())
  end.setDate(end.getDate() + colSpan - 1)

  # Return exercise record
  id: id, type: type, name: name
  start: new Date(currentDate.getTime()), end: end
  mailto: hrefs.mailto, spec: hrefs.spec
  givens: hrefs.givens, handin: hrefs.handin


# Add the parsed exercises to the given module
# module - the module to attach the exercises to
# exerciseCells - An array of cells (jQuery objects)
processExerciseCells = ($, $cells, moduleData, dates) ->

  # Return if cells are null
  if not $cells? then return null
  exercises = new Array()

  currentDate = parseDate dates.start
  currentDate.setDate(currentDate.getDate() - dates.colBufferToFirst)

  for exCell in $cells
    $exCell = $ exCell

    colSpan = parseInt($exCell.attr('colspan') ? 1)
    colSpan = 1 if colSpan == NaN

    if $exCell.attr('bgcolor')? and $exCell.find('a').length != 0
      ex = processExerciseCell $, $exCell, currentDate, colSpan
      ex.moduleName = moduleData.name
      ex.moduleID = moduleData.id
      exercises.push ex

    currentDate.setDate (currentDate.getDate() + colSpan)

  return exercises.sort (a,b) ->
    if a.start < b.start then -1 else 1

# Extracts the table containing exercises
getTimetable = ($) ->
  $('table[border="0"]:eq(0)')

# Extracts full title e.g. Spring Term 2012-2013
getTermTitle = ($) ->
  $('tr:eq(0) h1:eq(0)').text()

# Extracts the academic years applicable
# e.g. "Easter Period 2012-2013" -> ["2012", "2013"]
getAcademicYears = ($) ->
  $('h1').text()[-9..].split '-'

# Extracts the boundary dates for this timetable
getStartEndDates = ($) ->

  $timetable = getTimetable $
  years = getAcademicYears $

  # TODO: What if the timetable crosses year boundaries?
  #       e.g over new year/christmas?
  [firstMonth, others..., lastMonth] =
    extractMonths $, $timetable.find 'tr:eq(0)'

  year = if firstMonth < 9 then years[1] else years[0]

  $dayHeaders = $timetable.find 'tr:eq(2) th'

  colBuf = 0
  colBuf += 1 while $($dayHeaders[colBuf]).is(":empty")

  [firstDay, others..., lastDay] =
    extractDays $, $timetable.find('tr:eq(2)')

  # Remember Day in yyyy-mm-dd format
  start: new Date "#{year}-#{firstMonth}-#{firstDay}"
  end:   new Date "#{year}-#{lastMonth}-#{lastDay}"
  colBufferToFirst: colBuf - 1

# Parses all the modules present in the timetable
getModules = ($, dates) ->

  $timetable = getTimetable $

  # Returns whether or not an element is a module container
  # $elem - jQuery element
  isModule = ($elem) ->
    $elem.find('font[color="blue"]')

  $allRows = $timetable.find('tr')
  modules = new Array()
  count = 0

  while count < $allRows.length
    currentRow = $allRows[count]
    followingRowCount = 0
    $moduleElem = $(currentRow).find('td:eq(1)')
    if isModule($moduleElem).length > 0
      moduleData = processModuleCell $moduleElem

      followingRowCount = $(currentRow)
        .find('td:eq(0)')
        .attr('rowspan') - 1
      followingRows = $allRows[count+1..count+followingRowCount]

      $exCells = ($(row).find('td')[1..] for row in followingRows)
      $exCells.push($(currentRow).find('td')[4..])
      $exCells = (cs for cs in $exCells when cs?)

      exChunks = $exCells.map (cells) ->
        processExerciseCells $, cells, moduleData, dates
      moduleData.exercises = [].concat exChunks...
      modules.push moduleData
    count += followingRowCount + 1
  return modules

# Parses exercise data from the students timetable.
# Accepts data from ~/timetable.cgi?keyt=<YEAR>:<PERIOD>:<CLASS>:<USER>
module.exports = class ExercisesParser extends CateParser

  # Extract all timetabled exams from the student timetable page.
  extract: ($) ->
    dates = getStartEndDates $
    modules = getModules $, dates

    # Return parsed data
    year: @query.year
    period: @query.period
    start: dates.start
    end: dates.end
    modules: modules
    termTitle: getTermTitle $

  # Requires a specified year, period, student class and login.
  # Eg. {year: 2013, period: 3, class: 'c1', user: 'lmj112'}
  @url: (query) ->
    year   = query.year || @defaultYear()
    user   = query.user
    klass  = query.class
    period = query.period
    if not (year && user && klass)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/timetable.cgi?keyt=#{year}:#{period}:#{klass}:#{user}"

