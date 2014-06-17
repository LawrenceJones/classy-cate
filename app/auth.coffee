mongoose = require 'mongoose'
require './etc/db'
Student = mongoose.model 'Student'

module.exports = Auth =

  # Midware to guard unauthorized access by parsing jsonwebtokens
  midware: (req, res, next) ->
    Student.findOne login: req.user.login, (err, student) ->
      if err? or !(req.dbuser = student)?
        res.send 401, 'Token expired'
      else next()

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
    return res.send 401 if !(creds = validateParams req)
    isAuthed = Student.authenticate creds.login, creds.pass
    isAuthed
      .then (token) -> res.json token
      .catch (err) -> reject res, err

# Given an express app, configures auth utilities
Auth.configure = (app) ->
  app.use '/api', Auth.midware
  app.post '/authenticate', Auth.authenticate


