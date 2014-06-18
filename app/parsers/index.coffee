# Parser tools manifest
module.exports =

  HTTPProxy:  require '../proxies/http_proxy'
  HTMLParser: require './html_parser'

  # CATe Parsers
  cate:
    TimetableParser: require './cate/timetable_parser'

  # teachdb Parsers
  teachdb:
    StudentParser: require './teachdb/student_parser'
    StudentIDParser: require './teachdb/student_id_parser'

