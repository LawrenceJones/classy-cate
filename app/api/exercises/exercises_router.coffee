ExercisesProxy = require './exercises_proxy'

module.exports = (app) ->
  app.get '/api/exercises', routes.getExercises

routes =

  getExercises: (req, res) ->
    exercisesPromise = ExercisesProxy.makeRequest req.query, req.user
    exercisesPromise.then (data) ->
      res.json data
    exercisesPromise.catch (err) ->
      res.send err.code, err.msg



