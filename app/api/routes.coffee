Dashboard = require '../cate/dashboard'
Exercises = require '../cate/exercises'
Givens    = require '../cate/givens'
Notes     = require '../cate/notes'
Grades    = require '../cate/grades'

module.exports = (app) ->

  app.get '/api/dashboard', (req, res) ->
    Dashboard.get req, res
  app.get '/api/exercises', (req, res) ->
    Exercises.get req, res
  app.get '/api/givens', (req, res) ->
    Givens.get req, res
  app.get '/api/notes', (req, res) ->
    Notes.get req, res
  app.get '/api/grades', (req, res) ->
    Grades.get req, res

