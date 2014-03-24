$q = require 'q'

dashboard = require './dashboard'
exercises = require './exercises'
grades    = require './grades'

module.exports = (app) ->

  app.get '/api/dashboard', dashboard.getDashboard
  app.get '/api/exercises', exercises.getExercises
  app.get '/api/grades', grades.getGrades

