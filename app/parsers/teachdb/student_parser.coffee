HTMLParser = require '../html_parser'

# Strips text out of jQuery elem, without newlines or space
strip = ($elem) ->
  $elem.text()
    .replace /[\n\r]/g, ''
    .replace /(^[\s\t\r\n]*)|([\s\t\r\n]*$)/g, ''
    .trim()

# Type coercion for the string values from teachdb
T_Int = (i) -> parseInt i, 10
T_Date = (d) -> new Date(d)?.getTime()
T_Classes = (s) -> s.split /,\s*/g
T_Term = (s) -> T_Classes(s).map T_Int
T_Origin = (s='') -> s.toUpperCase()
T_Eid = (s) -> if s is '-' then null else s

# Translation for teachdb keys
dict =
  ValidFrom: ['validFrom', T_Date]
  ValidTo: ['validTo', T_Date]
  Id: ['tid', T_Int]
  Login: ['login', null]
  Email: ['email', null]
  Firstname: ['fname', null]
  Lastname: ['lname', null]
  Salutation: ['salutation', null]
  Source: ['origin', T_Origin]
  EntryYear: ['entryYear', T_Int]
  URL: ['url', null]
  CandidateNo: ['cand', null]

# Given a key and a value, will return transformed key and
# parsed value
keyParser = (key, val) ->
  return if not dict[key]?
  [key, Type] = dict[key]
  [key, Type?(val) ? val]

# Find the classes that are listed in a continuous streak, and
# return the number of times they appear consecutively.
findLongestRuns = (courses) ->
  [score,ended] = [{},{}]
  courses.map (course) ->
    for c in course.classes
      if ended[c]
        delete score[c] if score[c]?
      else score[c] = (score[c] ? 0) + 1
    for own c,v of score
      ended[c] = true if course.classes.indexOf(c) is -1
  return score

# Make guess at years of study from entry year
estimateYearsStudied = (year, now = new Date()) ->
  fourMonthsOn = new Date(now.getTime() + (5*31*24*60*60*1000))
  Math.max 1, (fourMonthsOn.getFullYear() - year)

# Generates all combinations of picking p from array A
combinations = (A, p) ->
  return [[]] if p == 0
  [n, i, combos, combo] = [A.length,0,[],[]]
  while combo.length < p
    if i < n then combo.push i++
    else
      break if combo.length == 0
      i = combo.pop() + 1
    if combo.length == p
      combos.push combo.map (c) -> A[c]
      i = combo.pop() + 1
  combos

# Returns the classes that are the best guess for the student given
# the estimated number of years in study.
# Now is an optional replacement for the current time, in place for unit
# testing.
bestGuessClasses = (courses, entryYear, now = new Date) ->
  noOfYears = estimateYearsStudied entryYear, now
  runs = findLongestRuns courses
  possible =
    combinations (Object.keys runs), 2
    .filter (comb) ->
      courses.length is comb.reduce ((a,c) -> a+runs[c]), 0
    .shift()

  
# Parses user details from teachdb
# Accepts data from ~/db/All/viewrec?table=Student&id=<TEACHDB_ID>
module.exports = class StudentParser extends HTMLParser

  # Export for unit testing
  @_helpers:
    findLongestRuns: findLongestRuns
    estimateYearsStudied: estimateYearsStudied
    combinations: combinations
    bestGuessClasses: bestGuessClasses

  # Extracts data from html
  extract: ($) ->

    user = new Object
    $('table[cellpadding=4] td[bgcolor=#cfdfdf]').map ->
      $key = $(this)
      $val = $key.next()
      if (kv = keyParser strip($key), $val.text().trim())?
        [key, val] = kv
        user[key] = val unless val is ''

    $courseTbl = $("h2:contains('Required Courses')").parent().parent()
    if $courseTbl.length is 0
      throw new Error 'Failed to find course table'

    user.courses = []
    $courseTbl.find('tr:gt(0)').map ->
      d = [cid, name, eid, _terms, _, _classes] =
        $(@).find('td:gt(0)').map -> strip $(@)
      terms = _terms.split(',').map (t) -> parseInt t, 10
      classes = _classes.split /,\s+/
      user.courses.push
        cid: cid, name: name, eid: T_Eid eid
        terms: terms, classes: classes

    # Try to guess students classes
    user.enrolment =
      (for c,i in bestGuessClasses(user.courses, user.entryYear) ? []
        year: user.entryYear+i, class: c)

    user['_meta'] =
      tid: user.tid
      login: user.login
    user

  # Requires a teachdb student ID
  # Eg. {tid: 10020175}
  @url: (query) ->
    tid = query.tid
    if not tid then throw Error 'Missing query parameters'
    "#{@TEACH_DOMAIN}/db/All/viewrec?table=Student&id=#{tid}"

