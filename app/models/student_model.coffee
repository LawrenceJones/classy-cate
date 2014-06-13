Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

studentSchema = Schema
  validFrom: Number
  validTo: Number
  tid: Number
  login: String
  email: String
  salutaion: String
  fname: String
  lname: String
  origin: String
  entryYear: Number
  url: String
  cand: Sring
  profile: String
  courses: [
    cid: String
    name: String
    eid: String
    terms: [Number]
    classes: [String]
  ]
  enrolment: [
    year: Number
    class: String
  ]

format =
  '1A': ->
    _meta:
      link: "/api/users/#{@login}"
      login: @login
      tid: @tid
    data:
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

studentSchema.methods.api = (version) ->
  switch version
    when '1A' then format['1A'].call @
    else throw new Error 'Format not supported'

module.exports = Student = mongoose.model 'Student', studentSchema

