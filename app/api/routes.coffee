$q = require 'q'

Dashboard = require '../cate/dashboard'
Exercises = require '../cate/exercises'

grades    = require './grades'
notes     = require './notes'
givens    = require './givens'

module.exports = (app) ->

  app.get '/api/dashboard', (req, res) ->
    Dashboard.get req, res
  app.get '/api/exercises', (req, res) ->
    Exercises.get req, res
  app.get '/api/grades', grades.getGrades
  app.get '/api/notes', notes.getNotes
  app.get '/api/givens', givens.getGivens

