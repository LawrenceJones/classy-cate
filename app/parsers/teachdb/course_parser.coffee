HTMLParser = require '../html_parser'

# Strips text out of jQuery elem, without newlines or space
strip = ($elem) ->
  $elem.text().replace(/[\n\r]/g, '').trim()

# Type coercion for the string values from teachdb
T_Int = (i) -> parseInt i, 10
T_Date = (d) -> new Date d
T_Classes = (s) -> s.split /,\s*/g
T_Term = (s) -> T_Classes(s).map T_Int

# Translation for teachdb keys
dict =
  ValidFrom: ['validFrom', T_Date]
  ValidTo: ['validTo', T_Date]
  Id: ['tid', T_Int]
  Title: ['name', null]
  Code: ['cid', T_Int]
  Term: ['terms', T_Term]
  LectureHours: ['lectureHours', T_Int]
  TutorialHours: ['tutorialHours', T_Int]
  LabHours: ['labHours', T_Int]
  WeeklyHours: ['weeklyHours', T_Int]
  PopEstimate: ['population', T_Int]
  Classes: ['classes', T_Classes]
  HelpersTotal: ['noOfHelpers', T_Int]
  Syllabus: ['syllabus', null]
  URL: ['url', null]
  Notes: ['notes', null]

# Given a key and a value, will return transformed key and
# parsed value
keyParser = (key, val) ->
  return if not dict[key]?
  [key, Type] = dict[key]
  [key, Type?(val) ? val]
  
# Parses course details from teachdb
# Accepts data from ~/db/<PERIOD>/viewrec?table=Course&id=<TEACHDB_ID>
module.exports = class CourseParser extends HTMLParser

  # Extracts data from html
  extract: ($) ->
    data = new Object()
    $('table[cellpadding=4] td[bgcolor=#cfdfdf]').map ->
      $key = $(this)
      $val = $key.next()
      if (kv = keyParser strip($key), $val.text().trim())?
        [key, val] = kv
        data[key] = val unless val is ''
    data

  # Requires a teachdb course ID and a period, defaulting to 'Curr'
  # Eg. {period: 'Curr', tid: 10020175}
  @url: (query) ->
    tid = query.tid
    period = query.period || 'Curr'
    if not (tid && period)
      throw Error 'Missing query parameters'
    "#{@TEACH_DOMAIN}/db/#{period}/viewrec?table=Course&id=#{tid}"

