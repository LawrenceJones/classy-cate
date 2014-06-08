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
  notes: [
    year:
      type: Number
    code: Number
    period: Number
    links: [
      restype: String
      title: String
      link: String
    ]
  ]
  exercises: []

NotesProxy = require '../notes/notes_proxy'
find = (array, elem, f) ->
  array?.reduce\
  ( ((a,c) -> return a if a?; c if f elem, c)
  , undefined )


# Given a module instance, and a notes structured like so...
#
#     { year, code, links: [] }
#
# Will load the contents of note into the module. If a note is
# already in place, then will load the content of note.links
# into the already existing array. Otherwise, note is just
# pushed to the module.notes collection.
upsertNote = (module, note, user) ->
  return if !module?.id?
  found = find module.notes, note, (a,b) ->
    "#{a.year}" == "#{b.year}"
  if !found?
    module.notes.push note
    NotesProxy.makeRequest note, user if user?
  else
    for link in note.links
      exists = find found.links, link, (a,b) -> a.title == b.title
      if !exists? then found.links.push link

# Given a data object structured like so...
#
#     { id, name, notesLink, exercises: [] }
#
# Will load this information into the database. If the module
# doesn't already exist then it is created, otherwise the
# instance is updated with new content and saved.
#
# Returns a promise that is resolved on successful db save.
cateModuleSchema.statics.loadModule = loadModule = (data, user) ->
  if data instanceof Array
    return $q.all(data.map (d) -> loadModule d, user)
  one = CateModule.findOne id: data.id
  one.exec (err, module) ->
    module ?= new CateModule data
    upsertNote module, note, user for note in data.notes
    module.save (err) ->
      return deferred.reject err if err?
      deferred.resolve module
  (deferred = $q.defer()).promise
  
# Adds any given notes to the current module, discards if
# module not found.
#
#     { moduleID, moduleName, year, code, links: [] }
#
# Not vital running procedure, no error checking required.
cateModuleSchema.statics.addNotes = addNotes = (data) ->
  if data instanceof Array
    return $q.all(data.map addNotes)
  one = CateModule.findOne id: data.moduleID
  one.exec (err, module) ->
    return def.reject err if err?
    upsertNote module, data
    module.save (err) ->
      if err?
        console.error err
        return def.reject err
      def.resolve module
  (def = $q.defer()).promise

# The following static method will move through the database
# and attempt to generate intelligent matches of cate modules
# against exams. It does this by analysing the titles and
# regexing any matched words.
cateModuleSchema.statics.generateRelated = ->
  allModules = CateModule.find {}
  allModules.exec (err, modules) ->
    Exam = mongoose.model 'Exam'
    Exam.find({}).exec (err, exams) -> exams.map (exam) ->
      matched = modules.filter (m) ->
        return false if !m.name?
        rstr = m.name.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"
        rex = new RegExp rstr, 'i'
        rex.test exam.titles?.reduce? (a,c) -> a || c
      matched.map (m) ->
        exam.related.addToSet m
      if matched.length > 0 then exam.save (err) ->
        console.error err if err?

CateModule = mongoose.model 'CateModule', cateModuleSchema
# Cate Resource access for Note parsing
module.exports = CateModule

