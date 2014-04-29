$q = require 'q'
# Require CATe tools
CateProxy = require '../cate/cate_proxy'
ExercisesParser = require './exercises_parser'
NotesProxy = require '../notes/notes_proxy'

# Mongoose access
mongoose = require 'mongoose'
CateModule = mongoose.model 'CateModule'

# Initialise the proxy with the exercises parser
class ExercisesProxy extends CateProxy

  # Override the standard makeRequest function in order to pipe
  # the parsed data into the CateModule database.
  makeRequest: (query, user) ->
    req = super query, user
    req.then (data) ->
      # Resolve the deferred, move along to database loading
      def.resolve data
      loaded = CateModule.loadModule data.modules, user
      loaded.then (modules) ->
        console.log 'Updated CateModules database!'
      loaded.catch (err) ->
        console.error err
      loaded.finally ->
        req = data = null # gc
    (def = $q.defer()).promise

    
module.exports = new ExercisesProxy(ExercisesParser)

