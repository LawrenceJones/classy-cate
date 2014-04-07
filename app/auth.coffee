jwt = require 'jsonwebtoken'
config = require './config'
Cate = require './cate'

module.exports = (app) ->

  app.use '/api', (req, res, next) ->
    if req.user? then next()
    else res.send 401, 'Token expired'


  app.post '/authenticate', (req, res) ->

    reject = (res, mssg) ->
      res.send 401, mssg || 'Invalid email/pass'

    creds = [user, pass] = [req.body.user, req.body.pass].map (c) ->
      c.replace /(^[\r\n\s]*)|([\r\n\s]*$)/g, ''
    valid = creds.reduce((a,c) ->
      a && c? && typeof c == 'string' && c != ''
    , true)
    if not valid then reject res, 'Either login or pass not supplied'
    else
      authed = Cate.auth user, pass
      authed.then ->
        token = jwt.sign {
          user: req.body.user
          pass: req.body.pass
        }, config.express.SECRET, {expiresInMinutes: 60*1}
        res.json
          token: token
      authed.catch (err) ->
        reject res, 'Authentication failed'



