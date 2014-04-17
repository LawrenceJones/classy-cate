jwt = require 'jsonwebtoken'
config = require '../etc/config'
CateProxy = require './cate_proxy'

# In minutes
TOKEN_EXPIRY = 12 * 60

module.exports = (app) ->

  # Displays logins that have been used this session
  app.get '/users', (req, res) ->
    res.json Object.keys(config.users)

  # Returns the users login
  app.get '/api/whoami', (req, res) ->
    res.json req.user.user

  # Post over SSL, credentials stored in parameters as
  # {user, pass}. If authing against cate is successful
  # then server json web token.
  app.post '/authenticate', (req, res) ->

    reject = (res, mssg) ->
      res.send 401, mssg || 'Invalid email/pass'

    creds = [user, pass] = [req.body.user, req.body.pass].map (c = '') ->
      c.replace /(^[\r\n\s]*)|([\r\n\s]*$)/g, ''
    valid = creds.reduce (a = true, c) ->
      a && c? && typeof c == 'string' && c != ''
    if not valid then reject res, 'Either login or pass not supplied'
    else
      authed = Cate.auth user, pass
      authed.then ->
        config.users[req.body.user] = true
        token = jwt.sign {
          user: req.body.user
          pass: req.body.pass
        }, config.express.SECRET, expiresInMinutes: TOKEN_EXPIRY
        res.json
          token: token
      authed.catch (err) ->
        reject res, 'Authentication failed'



