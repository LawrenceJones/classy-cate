$q = require 'q'
config = require '../etc/config'

# Mongoose
mongoose = require 'mongoose'
CateModule = mongoose.model 'CateModule'

# Configure modules proxy
CateProxy = require '../cate/cate_proxy'
ModulesProxy = new CateProxy(require './modules_parser')

module.exports = (app) ->
  # Index modules that user is subscribed to
  app.get '/api/subscribed_modules', routes.getSubscribed
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

  # GET /api/subscribed_modules
  # Returns a json hash of module id against the level of subscription.
  getSubscribed: (req, res) ->
    ModulesProxy.makeRequest req.query, req.user
      .then (modules) ->
        res.json modules
      .catch (err) ->
        console.error err.msg
        res.send err.code
    




