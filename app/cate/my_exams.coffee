$ = require 'cheerio'
CateResource = require './resource'

# Extracts each exam the user is subscribed to.
parseExam = ($row) ->
  [fulltitle, date, time, duration, room] = $row
    .find 'td'
    .toArray()
    .map (td) -> $(td).text().trim()
  [id, title] = fulltitle.split ': '
  if not (id && title) then return
  id: id, title: title
  date: date, time: time
  duration: duration, room: room

# Extracts timetable from a jquery page.
getTimetable = ($page) ->
  $tt = $page.elemAt 'table', 0
  $rows = $tt.find('tr')[1..]
  (parseExam ($ row) for row in $rows).filter (a) -> a

# Scrapes the exams the user is subscribed to.
module.exports = class MyExams extends CateResource

  parse: ($page) ->
    @data =
      exams: getTimetable $page

  @url: (req) ->
    'https://exams.doc.ic.ac.uk/prog/candidate.cgi'

