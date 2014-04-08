$q = require 'q'
request = require 'request'

module.exports = class Cate

  @Dashboard:  require  './dashboard'
  @Exercises:  require  './exercises'
  @Givens:     require  './givens'
  @Notes:      require  './notes'
  @Grades:     require  './grades'
  @CateExams:  require  './exams'

  # Takes user login and password, resolves promise on whether
  # CATE has accepted the credentials.
  @auth: (user, pass) ->
    deferred = $q.defer()
    options =
      url: 'https://cate.doc.ic.ac.uk'
      auth:
        user: user
        pass: pass
        sendImmediately: true
    request options, (err, data, body) ->
      if data.statusCode is 401
        deferred.reject 401
      else
        deferred.resolve data.statusCode
    deferred.promise



