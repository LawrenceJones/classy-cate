NotesParser = require './notes_parser'
NotesProxy = new (require '../cate/cate_proxy')(NotesParser)

module.exports = (app) ->
  app.get '/api/notes', routes.getNotes

routes =

  getNotes: (req, res) ->
    notesPromise = NotesProxy.makeRequest req.query, req.user
    notesPromise.then (data) ->
      res.json data
    notesPromise.catch (err) ->
      res.send err.code, err.mssg



