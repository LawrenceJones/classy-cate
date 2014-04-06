$ = require 'cheerio'
CateResource = require './resource'

parseExam = ($row) ->
  $cells = $row.find 'td'
  obj = {}
  for key,i in ['title', 'date', 'time', 'duration', 'room']
    obj[key] = $($cells[i]).text()
  return obj

module.exports = class MyExams extends CateResource

  getTimetable: ->
    $tt = @$page.elemAt 'table', 0
    $rows = $tt.find('tr')[1..]
    (parseExam ($ row) for row in $rows)

  parse: ->
    @data =
      exams: @getTimetable()

  @url: (req) ->
    'https://exams.doc.ic.ac.uk/prog/candidate.cgi'

