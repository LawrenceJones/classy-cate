GradesParser = require './grades_parser'
GradesProxy = new (require '../cate/cate_proxy')(GradesParser)

module.exports = (app) ->
  app.get '/api/grades', routes.getGrades

routes =

  getGrades: (req, res) ->
    gradesPromise = GradesProxy.makeRequest req.query, req.user
    gradesPromise.then (data) ->
      res.json data
    gradesPromise.catch (err) ->
      res.send err.code, err.msg



