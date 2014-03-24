module.exports = (app) ->

  app.use '/api', (req, res, next) ->
    if req.user? then next()
    else res.send 401, 'Token expired'


