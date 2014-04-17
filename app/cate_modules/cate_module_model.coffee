config = require '../config'
$q = require 'q'
# CateModule model
Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

cateModuleSchema = mongoose.Schema
  id:
    type: String
    trim: true
    required: true
    index:
      unique: true
      dropDups: true
  name:
    type: String
    trim: true
    required: true
  notesLink:
    type: String
    trim: true
  notes: [
    type:
      type: String
      trim: true
    title:
      type: String
      default: 'UNNAMED'
      trim: true
    link:
      type: String
      trim: true
      required: true
      unique: true
      sparse: true
  ]
  exercises: []


# Format the notesLink field into an appropriate value.
notesRex = /notes\.cgi\?key=(\d+):(\d+)/
cateModuleSchema.pre 'init', (next) ->
  @notesLink = @notesLink?.match?(notesRex)[0]
  do next

# Attempts to load the information given in data into the
# current database. Ensures that when loaded, stale data
# is updated but no data is destroyed.
cateModuleSchema.statics.register = register = (data, req) ->
  if data instanceof Array
    return $q.all (register elem, req for elem in data)
  # Can now guarantee data is a single entity
  update = CateModule.findOneAndUpdate\
  ( id: data.id
  , data
  , upsert: true)
  update.exec (err, module) ->
    console.log data
    console.log err
    if err? then return deferred.reject err
    deferred.resolve module
    if module.notesLink?
      Notes.scrape(req, module.notesLink).then (notes) ->
        module.addNotes notes
  (deferred = $q.defer()).promise

# Given the url as an index into the module database, will
# add the given notes.
cateModuleSchema.statics.updateModuleNotes = (id, notes) ->
  CateModule.findOne id: id, (err, module) ->
    module?.addNotes notes
  
# Adds any given notes to the current module, discards if
# module not found.
# Not vital running procedure, no error checking required.
cateModuleSchema.methods.addNotes = (notes) ->
  for note in notes
    @notes.addUnique note, (a,b) ->
      a.title == b.title # links are user specific
  @save (err) ->
    console.error err.toString() if err?

CateModule = mongoose.model 'CateModule', cateModuleSchema
# Cate Resource access for Note parsing
Notes = require '../cate/notes'
module.exports = CateModule

