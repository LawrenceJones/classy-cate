GivensParser = require './givens_parser'
GivensProxy = new (require '../cate/cate_proxy')(GivensParser)

module.exports = (app) ->
  app.get '/api/givens', routes.getGivens

routes =

  getGivens: (req, res) ->
    givensPromise = GivensProxy.makeRequest req.query, req.user
    givensPromise.then (data) ->
      res.json data
    givensPromise.catch (err) ->
      res.send err.code, err.msg



