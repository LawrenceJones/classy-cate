Cate = require '../cate'

# Allow easy access to modules
Dashboard = Cate.Dashboard
Exercises = Cate.Exercises
Givens = Cate.Givens
Notes = Cate.Notes
Grades = Cate.Grades
Givens = Cate.Givens
CateExams = Cate.CateExams

module.exports = (app) ->

  app.get '/api/dashboard', (req, res) ->
    Dashboard.get req, res
  app.get '/api/givens', (req, res) ->
    Givens.get req, res
  app.get '/api/notes', (req, res) ->
    Notes.get req, res
  app.get '/api/grades', (req, res) ->
    Grades.get req, res
  app.get '/api/givens', (req, res) ->
    Givens.get req, res

  app.get '/api/exercises', (req, res) ->
    Exercises.get req, res
  app.get '/api/modules', (req, res) ->
    Exercises.indexModules req, res

  app.get '/api/myexams', (req, res) ->
    CateExams.getMyExams req, res
  app.get '/api/exams', (req, res) ->
    CateExams.index req, res
  app.post '/api/exams/:id/relate', (req, res) ->
    CateExams.relate req, res
  app.delete '/api/exams/:id/relate', (req, res) ->
    CateExams.removeRelated req, res
  app.get '/api/exams/:id', (req, res) ->
    CateExams.get req, res

