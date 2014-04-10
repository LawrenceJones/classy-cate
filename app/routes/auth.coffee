jwt = require 'jsonwebtoken'
config = require '../config'
Cate = require '../cate'

# In minutes
TOKEN_EXPIRY = 12 * 60

module.exports = (app) ->

  # Trigger 401 to reject user on no token
  app.use '/api', (req, res, next) ->
    if req.user? then next()
    else res.send 401, 'Token expired'

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
    valid = creds.reduce((a,c) ->
      a && c? && typeof c == 'string' && c != ''
    , true)
    if not valid then reject res, 'Either login or pass not supplied'
    else
      authed = Cate.auth user, pass
      authed.then ->
        config.users[req.body.user] = true
        token = jwt.sign {
          user: req.body.user
          pass: req.body.pass
        }, config.express.SECRET, {expiresInMinutes: TOKEN_EXPIRY}
        res.json
          token: token
      authed.catch (err) ->
        reject res, 'Authentication failed'



