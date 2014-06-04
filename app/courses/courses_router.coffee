path = require 'path'
fs = require 'fs'

module.exports = (app) ->
  app.get '/api/courses/:year/:id', routes.getCourse

routes =

  getCourse: (req, res) ->
    p = path.join(__dirname + '../../../public/json/api.courses.2013.202.json')
    res.json JSON.parse (fs.readFileSync p, 'utf-8')
