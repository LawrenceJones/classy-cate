jwt = require 'jsonwebtoken'
config = require '../etc/config'
CateProxy = require '../cate/cate_proxy'

module.exports = (app) ->

  # Auths user against CATe
  app.post '/authenticate', (req, res) ->

    input = [user, pass] = [req.body.user, req.body.pass]
    valid = input.reduce (a = true, c) ->
      a && c? && typeof c == 'string' && c.trim() != ''
    if not valid
      return res.send 400, 'Non-valid user/pass supplied'

    # Attempt auth against CATe
    CateProxy.auth(user, pass)
    .then ->
      token  = jwt.sign\
      ( user: user, pass: pass
      , config.express.SECRET
      , expiresInMinutes: config.jwt.TOKEN_EXPIRY )
      res.json token: token
    .catch (err) ->
      res.send 401, 'Invalid user credentials'

  # Generates the security audit results
  app.get '/audit', require './auth_audit'

