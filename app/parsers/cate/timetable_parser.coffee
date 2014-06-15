HTMLParser = require '../html_parser'

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

# Given a notes url, will regex out the appropriate query
# parameters.
processNotesLink = (href) ->
  rex = /notes\.cgi\?key=(\d+):(\d+):(\d+)/
  return null if !rex.test href
  [_, year, code, period] = href?.match?(rex).map? (n) -> parseInt n, 10
  year: year, code: code, period: period

# Extracts course details from a cell jQuery object
processCourseCell = ($cell) ->
  [cid, name] = $cell.text().split(' - ')
  cid: cid
  name: name.replace(/^\s+|\s+$/g, '')
  notes: processNotesLink $cell.find('a:eq(0)').attr('href')

# Parses an exercise from the given cell
processExerciseCell = ($, $exCell, currentDate, colSpan) ->

  # Extracts both eid and type of exercise, returns [eid, type]
  extractIdType = ->
    $exCell # [eid, type]
      .find 'b:eq(0)'
      .text().split(':')

  # Extracts the links
  extractHrefs = ->

    # Each link has it's own regular express test
    rex =
      mailto:  /mailto/i
      spec:    /SPECS/i
      givens:  /given\.cgi\?key=(\d+):(\d+):(\d+):(\w*)/i
      handin:  /handins/i

    links = new Object()
    hrefs = $exCell.find('a').toArray().reduce ((a,c) ->
      $c = $ c; if $c.attr('href')? then a.push $c.attr 'href'; a), []
    hrefs.map (href) ->
      if rex.mailto.test href
        links.mailto = href
      else if rex.spec.test href
        links.spec = href
      else if rex.handin.test href
        links.handin = href
      else if rex.givens.test href
        [_, year, period, code, klass] = href.match rex.givens
        links.givens =
          year: parseInt year, 10
          period: parseInt period, 10
          code: parseInt code, 10
          class: klass
    return links

  [eid, type] = extractIdType $exCell
  hrefs = extractHrefs()

  name = $exCell
    .text()[(eid.length + type.length + 2)..]
    .replace(/[\s\n\r\b]*$/, '')
  end = new Date(currentDate.getTime())
  end.setDate(end.getDate() + colSpan - 1)

  typeCols = (col) ->
    # [group, assessed, submitted]
    if /^#f0ccf0$/i.test col
      [true, true, true]
    else if /^#cdcdcd$/i.test col
      [false, false, true]
    else if /^(#FFFFFF|white)$/i.test col
      [false, false, false]
    else if /^#CCFFCC$/i.test col
      [false, true, true]

  cellCol = $exCell.attr 'bgcolor'
  [group, assessed, submitted] = typeCols cellCol

  # Return exercise record
  eid: parseInt(eid, 10), type: type, name: name
  start: currentDate.getTime(), end: end.getTime()
  mailto: hrefs.mailto ? null, spec: hrefs.spec ? null
  givens: hrefs.givens ? null, handin: hrefs.handin ? null
  submission: submitted, group: group, assessed: assessed


# Add the parsed exercises to the given course
# course - the course to attach the exercises to
# exerciseCells - An array of cells (jQuery objects)
processExerciseCells = ($, $cells, courseData, dates) ->

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
      exercises.push processExerciseCell $, $exCell, currentDate, colSpan

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
  start: "#{year}-#{firstMonth}-#{firstDay}"
  end:   "#{year}-#{lastMonth}-#{lastDay}"
  colBufferToFirst: colBuf - 1

# Parses all the courses present in the timetable
getCourses = ($, dates) ->

  $timetable = getTimetable $

  # Returns whether or not an element is a course container
  # $elem - jQuery element
  isCourse = ($elem) ->
    $elem.find('font[color="blue"]')

  $allRows = $timetable.find('tr')
  courses = new Array()
  count = 0

  while count < $allRows.length
    currentRow = $allRows[count]
    followingRowCount = 0
    $courseElem = $(currentRow).find('td:eq(1)')
    if isCourse($courseElem).length > 0
      courseData = processCourseCell $courseElem

      followingRowCount = $(currentRow)
        .find('td:eq(0)')
        .attr('rowspan') - 1
      followingRows = $allRows[count+1..count+followingRowCount]

      $exCells = ($(row).find('td')[1..] for row in followingRows)
      $exCells.push($(currentRow).find('td')[4..])
      $exCells = (cs for cs in $exCells when cs?)

      exChunks = $exCells.map (cells) ->
        processExerciseCells $, cells, courseData, dates
      courseData.exercises = [].concat exChunks...
      courses.push courseData
    count += followingRowCount + 1
  return courses

# Parses exercise data from the students timetable.
# Accepts data from ~/timetable.cgi?keyt=<YEAR>:<PERIOD>:<CLASS>:<USER>
module.exports = class TimetableParser extends HTMLParser

  # Extract all timetabled exams from the student timetable page.
  extract: ($) ->
    dates = getStartEndDates $
    courses = getCourses $, dates

    # Return parsed data
    _meta:
      year:   parseInt @query.year, 10
      period: parseInt @query.period, 10
      start: new Date(dates.start).getTime()
      end:   new Date(dates.end).getTime()
      title: getTermTitle $
    courses: courses

  # Requires a specified year, period, student class and login.
  # Eg. {year: 2013, period: 3, class: 'c1', user: 'lmj112'}
  @url: (query) ->
    year   = query.year || @defaultYear()
    user   = query.user
    klass  = query.class
    period = query.period
    if not (year && period && klass)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/timetable.cgi?keyt=#{year}:#{period}:#{klass}:#{user}"

