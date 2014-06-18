# API Versioned formatters for our Student records.
module.exports = formats =

  '1A': ->
    _meta:
      link: "/api/users/#{@login}"
      login: @login
      tid: @tid
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
    courses: @courses.map (c) ->
      _meta:
        link: "/api/courses/#{c.year}/#{c.cid}"
        year: c.year
        cid: c.cid
      data:
        cid: c.cid
        name: c.name
        eid: c.eid
        terms: c.terms
        classes: c.classes
    enrolment: @enrolment

