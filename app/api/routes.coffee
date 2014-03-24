$q = require 'q'

dashboard = require './dashboard'
exercises = require './exercises'

module.exports = (app) ->

  app.get '/api/dashboard', dashboard.getDashboard
  app.get '/api/exercises', exercises.getExercises

