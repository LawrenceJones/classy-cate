mongoose = require 'mongoose'
Model = mongoose.Model
$q = require 'q'

# Returns all of the entities in the database, formatted
# with the given format key.
Model::index = (format = 'default') ->
  @find {}, (err, models) ->
    return def.reject err if err?
    models.map (m) -> m.format format
    def.resolve models
  return (def = $q.defer()).promise
    

