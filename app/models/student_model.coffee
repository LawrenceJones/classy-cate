$q = require 'q'
Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId
jwt = require 'jsonwebtoken'

Api = require 'app/api'
ApiFormats = require './student_model.api'

config = require 'app/etc/config'
require 'app/etc/db'

HTTPProxy = require 'app/proxies/http_proxy'
StudentProxy = new HTTPProxy require 'app/parsers/teachdb/student_parser'
StudentIDProxy = new HTTPProxy require 'app/parsers/teachdb/student_id_parser'

studentSchema = mongoose.Schema
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
  cand: String
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

# Register Student API formatters
Api.register studentSchema, ApiFormats

# Shorthand method for registering a student with plain json data,
# used to fill test database.
register = (data, cb) ->
  student = new Student data
  student.save (err) ->
    cb? err, student

# Generates promise that is resolved with student from database.
#
#   LOGIN: College login of student
#
# Returns a promise that is resolved with a database student object.
getDbStudent = (login) ->
  def = $q.defer()
  Student.findOne login: login, (err, student) ->
    if err then def.reject err
    else def.resolve student
  def.promise

# Given a students login, returns a promise that is resolved with the
# students teachdb ID.
#
#   LOGIN: College login
#   CREDS: Authentication credentials
#
# Returns a promise that is resolved with an object in the form...
#
#   tid: tid
#
# Login is excluded for consistency and frankly very little need.
getTid = (login, creds) ->
  getDbStudent(login).then (student) ->
    if student?.tid then tid: student.tid
    else StudentIDProxy.makeRequest login: login, creds

# Takes a LOGIN and optional TID value.
#
#   LOGIN: College login
#   CREDS: Authentication credentials
#   TID:   Optional teachdb ID of student, to skip indexing
#
# Returns a promise that is resolved with a student mongoose object.
getTeachdbStudent = (login, creds, tid = false) ->
  $q.fcall ->
    if tid then tid: tid else getTid login, creds
  .then (query) ->
    StudentProxy.makeRequest query, creds

# Fetches a student, either from our database or from teachdb if no
# record is present.
#
#   LOGIN: College login
#   CREDS: Authentication credentials
#   FORCE: Will rescrape Teachdb without supplying database
#
# Returns a promise that is resolved with a student object.
getStudent = (login, creds, force = false) ->
  getDbStudent(login).then (student) ->
    if student and not force then student
    else getTeachdbStudent login, creds, student?.tid

# Given a javascript payload, signs into a jsonwebtoken using the
# servers secret key. Used to attach to req.user.
jwtSign = (payload, expiry = config.express.AUTH_EXPIRY) ->
  jwt.sign\
  ( payload
  , config.express.SECRET
  , expiresInMinutes: expiry )

# Allows a student instance to sign itself, given the password.
studentSchema.methods.signToken = (password, expiry) ->
  @token = jwtSign user: @login, pass: password, expiry
  return @

# Wraps around the getStudent function to allow easier authentication.
# If successful, the returned promise will be resolved with user data
# along with a token located in the _meta child.
#
#   LOGIN: College login
#   PASS:  Password for Imperial systems
#
# Forces a real request into teachdb. The student instance has a fresh
# auth token signed into it's _meta field which the client can then
# pick up.
authWrapper = (login, pass) ->
  creds = user: login, pass: pass
  getStudent(login, creds).then (student) ->
    student.signToken pass

Student = mongoose.model 'Student', studentSchema
module.exports =

  # Basic model content
  model: Student
  formats: ApiFormats
  schema: studentSchema

  # Helper functions
  register: register
  get: getStudent
  getTeachdb: getTeachdbStudent
  getTid: getTid
  auth: authWrapper
  sign: jwtSign

