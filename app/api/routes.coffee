$q = require 'q'
Dashboard = require '../cate/dashboard'

exercises = require './exercises'
grades    = require './grades'
notes     = require './notes'
givens    = require './givens'

module.exports = (app) ->

  app.get '/api/dashboard', (req, res) ->
    Dashboard.get req, res
  app.get '/api/exercises', exercises.getExercises
  app.get '/api/grades', grades.getGrades
  app.get '/api/notes', notes.getNotes
  app.get '/api/givens', givens.getGivens

