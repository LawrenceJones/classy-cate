CateParser = require '../cate/cate_parser'

# Extracts each exam the user is subscribed to.
parseExam = ($, $row) ->

  # Extract cell text contents
  [fulltitle, date, time, duration, room] =
    $row.find('td').map -> $(@).text().trim()
  [id, title] = fulltitle.split ': '

  # Parse ints in order to process date
  [hr, min] = time.split(':').map (v) ->
    parseInt v, 10
 
  # Parses the simple date and month, date probably looks
  # like '28-Apr'. Assume the year is the current.
  datetime = new Date date
  datetime.setYear new Date().getFullYear()
  datetime.setHours hr
  datetime.setMinutes min
  if not (id && title) then return

  # Return the exam object
  id: id
  title: title
  room: room
  datetime: datetime
  duration: duration

# Parses data about a students exam timetable.
# Accepts data from https://exams.doc.ic.ac.uk/prog/candidate.cgi
module.exports = class ExamTimetableParser extends CateParser

  # Extract all timetabled exams from the student timetable page.
  extract: ($) ->
    exams = []
    $('table:eq(0) tr')[1..].map ->
      exams.push parseExam $, $(@)
    exams: exams

  # No query details required for this url.
  @url: ->
    "#{@EXAM_DOMAIN}/prog/candidate.cgi"

