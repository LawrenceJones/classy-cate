config = require '../etc/config'
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
    year: String
    code: String
  notes: [
    title:
      type: String
      index: true
      sparse: true
      unique: true
      trim: true
    link:
      type: String
      trim: true
      required: true
  ]
  exercises: []


# Given a data object structured like so...
#
#     { id, name, notesLink, exercises: [] }
#
# Will load this information into the database. If the module
# doesn't already exist then it is created, otherwise the
# instance is updated with new content and saved.
#
# Returns a promise that is resolved on successful db save.
NotesProxy = require '../notes/notes_proxy'
cateModuleSchema.statics.loadModule = loadModule = (data, user) ->
  if data instanceof Array
    return $q.all(data.map (d) -> loadModule d, user)
  update = CateModule.findOneAndUpdate\
  ( id: data.id
  , data
  , upsert: true)
  update.exec (err, module) ->
    console.error err if err?
    throw err if err?
    if module.notesLink?.year && module.notesLink?.code
      NotesProxy.makeRequest module.notesLink, user
    deferred.resolve module
  (deferred = $q.defer()).promise
  
# Adds any given notes to the current module, discards if
# module not found.
#
#     { moduleID, moduleName, year, code, notes: [] }
#
# Not vital running procedure, no error checking required.
cateModuleSchema.statics.addNotes = addNotes = (data) ->
  if data instanceof Array
    return $q.all(data.map addNotes)
  update = CateModule.findOneAndUpdate\
  ( id: data.moduleID
  , data
  , upsert: true )
  update.exec (err, module) ->
    return deferred.reject err if err?
    deferred.resolve module
  (deferred = $q.defer()).promise

CateModule = mongoose.model 'CateModule', cateModuleSchema
# Cate Resource access for Note parsing
module.exports = CateModule

