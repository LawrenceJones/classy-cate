jwt = require 'jsonwebtoken'
config = require '../etc/config'
CateProxy = require '../cate/cate_proxy'

module.exports = (app) ->

  # Displays logins that have been used this session
  app.get '/users', (req, res) ->
    res.json Object.keys(config.users)

  # Returns the users login
  app.get '/api/whoami', (req, res) ->
    res.json req.user.user

  app.post '/authenticate', routes.authenticate


routes =

  # Post over SSL, credentials stored in parameters as
  # {user, pass}. If authing against cate is successful
  # then server json web token.
  authenticate: (req, res) ->

    reject = (res, mssg) ->
      res.send 401, mssg || 'Invalid email/pass'

    creds = [user, pass] = [req.body.user, req.body.pass].map (c = '') ->
      c.replace /(^[\r\n\s]*)|([\r\n\s]*$)/g, ''
    valid = creds.reduce (a = true, c) ->
      a && c? && typeof c == 'string' && c != ''
    if not valid then reject res, 'Either login or pass not supplied'
    else
      authed = CateProxy.auth user, pass
      authed.then ->
        config.users[req.body.user] = true
        creds  = user: req.body.user, pass: req.body.pass
        secret = config.express.SECRET
        expiry = config.jwt.TOKEN_EXPIRY
        token  = jwt.sign creds, secret, expiresInMinutes: expiry
        res.json token: token
      authed.catch (err) ->
        reject res, 'Authentication failed'
