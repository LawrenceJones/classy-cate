mongoose = require 'mongoose'
Student = require 'app/models/student_model'
HTTPProxy = require 'app/proxies/http_proxy'
require 'app/etc/db'

module.exports = Auth =

  # Midware to guard unauthorized access by parsing jsonwebtokens
  midware: (req, res, next) ->
    Student.findOne login: req.user.login, (err, student) ->
      if err? or !(req.dbuser = student)?
        res.send 401, 'Token expired'
      else next?()

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
    isAuthed = Student.auth creds.login, creds.pass
    isAuthed
      .then (data) ->
        res.json new Student.model(data).api()
      .catch (err) -> res.send err ? 401
      .done()

  # Guard the reauth route with the same jwt protection as /api
  # routes, verifying that the user is actually logged in and behind
  # a security wall before we release any sensitive data.
  reauthenticate: (req, res) ->
    res.json req.dbuser.signToken(req.user.pass).api()


# Given an express app, configures auth utilities
Auth.configure = (app) ->
  # Guard the entirety of /api
  app.use '/api', Auth.midware
  # Token signing
  app.post '/authenticate', Auth.authenticate
  app.patch '/authenticate', Auth.midware, Auth.reauthenticate


