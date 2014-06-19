mongoose = require 'mongoose'
Student = require 'app/models/student_model'
HTTPProxy = require 'app/proxies/http_proxy'
require 'app/etc/db'
$q = require 'q'

module.exports = Auth =

  # Midware to guard unauthorized access by parsing jsonwebtokens
  midware: (req, res, next) ->
    $q.fcall ->
      Student.getDbStudent req.user.login
    .then (student) ->
      req.dbuser = student
      next?()
    .catch -> res.send 401, 'Token expired'
    .done()

  # Validates user credentials. Only if both login and password
  # have been supplied will this function return a truthy value.
  validate: (params) ->
    creds = [login, pass] = [params.login, params.pass]
    valid = creds.reduce((a,c) ->
      a && c? && typeof c == 'string' && c != ''
    , true)
    if valid then login: login, pass: pass else false

  # Request handler for POST to authenticate. Verifies contents of
  # request body in User database, and will response with either a
  # token or a 401.
  authenticate: (req, res) ->
    return res.send 401 if !(creds = Auth.validate req.body)
    Student.auth req.body.login, req.body.pass
    .then (student) ->
      res.json student.api()
    .catch (err) ->
      res.send 401
    .done()

  # Guard the reauth route with the same jwt protection as /api
  # routes, verifying that the user is actually logged in and behind
  # a security wall before we release any sensitive data.
  reauthenticate: (req, res) ->
    res.json req.dbuser.signToken(req.user.pass).api()

  # Returns the current users details.
  whoami: (req, res) ->
    if req.user?
      res.json Student.getDb(req.user.login).api()
    else res.send 404, 'Not found'


# Given an express app, configures auth utilities
Auth.configure = (app) ->

  # Guard the entirety of /api
  app.use '/api', Auth.midware
  app.get '/whoami', Auth.whoami

  # Token signing
  app.post '/authenticate', Auth.authenticate
  app.put '/authenticate', Auth.midware, Auth.reauthenticate


