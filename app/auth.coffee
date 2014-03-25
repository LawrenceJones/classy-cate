jwt = require 'jsonwebtoken'
config = require './config'

module.exports = (app) ->

  app.use '/api', (req, res, next) ->
    if req.user? then next()
    else res.send 401, 'Token expired'


  app.post '/authenticate', (req, res) ->

    reject = (res, mssg) ->
      res.send 401, mssg || 'Invalid email/pass'

    creds = [email, pass] = [req.body.email, req.body.pass]
    valid = creds.reduce((a,c) ->
      a && c? && typeof c == 'string' && c != ''
    , true)
    if not valid then reject res, 'Either email or pass not supplied'
    else
      token = jwt.sign {
        user: req.body.user
        pass: req.body.pass
      }, config.express.SECRET, {expiresInMinutes: 60*1}
      res.json token



