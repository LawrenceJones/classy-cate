$q = require 'q'

dashboard = require './dashboard'

module.exports = (app) ->

  app.get '/api/dashboard', dashboard.getDashboard

