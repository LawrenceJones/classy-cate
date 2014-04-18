$q = require 'q'
config = require '../etc/config'

# Mongoose
mongoose = require 'mongoose'
CateModule = mongoose.model 'CateModule'

module.exports = (app) ->
  # Indexes all the modules in the database
  app.get '/api/modules', routes.index
  # Gets a singular module from the db
  app.get '/api/modules/:id', routes.getOne

routes =

  # GET /api/modules
  # Renders json index of all the modules in the database.
  index: (req, res) ->
    all = CateModule.find {}
    all.exec (err, modules) ->
      res.json modules.map (m) ->
        id: m.id, name: m.name

  # GET /api/modules/:id
  # Returns a single module from the database.
  getOne: (req, res) ->
    one = CateModule find id: req.params.id
    one.exec (err, module) ->
      console.error err if err?
      res.json module



