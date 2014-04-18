$q = require 'q'
# Require CATe tools
CateProxy = require '../cate/cate_proxy'
NotesParser = require './notes_parser'

# Mongoose access
mongoose = require 'mongoose'

# Initialise the proxy with the exercises parser
class NotesProxy extends CateProxy

  # Override the standard makeRequest function in order to load
  # notes data into the CateModules database.
  makeRequest: (query, user) ->
    console.log 'Querying'
    console.log query
    req = super query, user
    req.then (data) ->
      # Resolve the deferred, move along to database loading
      def.resolve data
      loaded = mongoose.model('CateModule').addNotes data
      loaded.then (modules) ->
        console.log 'Loaded notes into CateModules!'
      loaded.catch (err) ->
        console.error err
    (def = $q.defer()).promise

    
module.exports = new NotesProxy(NotesParser)

