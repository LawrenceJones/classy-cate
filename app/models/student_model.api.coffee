# API Versioned formatters for our Student records.
module.exports = formats =

  '1A': ->
    _meta:
      link: "/api/users/#{@login}"
      login: @login
      tid: @tid
      token: @token ? null
    validFrom: @validFrom
    validTo: @validTo
    tid: @tid
    login: @login
    email: @email
    salutation: @salutation
    fname: @fname
    lname: @lname
    origin: @origin
    entryYear: @entryYear
    url: @url
    cand: @cand
    profile: @profile
    courses: @courses.map (c) =>
      year = null
      for e in @enrolment
        year ?= e.year if c.classes.indexOf(e.class) != -1
      _meta:
        link: "/api/courses/#{year}/#{c.cid}"
      cid: c.cid
      year: year
      name: c.name
      eid: c.eid
      terms: c.terms
      classes: c.classes
    enrolment: @enrolment

