$q = require 'q'
HTTPProxy = require 'app/proxies/http_proxy'
StudentParser = require 'app/parsers/teachdb/student_parser'

# Mongoose access
mongoose = require 'mongoose'
try mongoose.model 'Exam'
catch err
  (require '../etc/db')(require('../etc/config'), false)
Student = mongoose.model 'Student'

# Initialise the proxy
class StudentProxy extends HTTPProxy

  # Given user credentials, and tid, will scrape teachdb and
  # parse student data, then on successful load into the database
  # will resolve the returned promise.
  scrapeStudent: (user, tid, def = $q.defer()) ->
    req = @makeRequest tid: tid, user
    req.then (student) ->
      console.log student
      update = Student.update\
      ( login: student.login
      , student
      , upsert: true )
      update.exec (err, student) ->
        if err? then return def.reject msg: """
        Failed to load student data into database""", err: err
        def.resolve student
    def.promise
        
    
    
module.exports = new StudentProxy(StudentParser)

