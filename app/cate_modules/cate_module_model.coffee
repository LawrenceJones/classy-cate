config = require '../config'
$q = require 'q'
# CateModule model
Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId
# Cate Resource access for Note parsing
Notes = require '../cate/notes'

cateModuleSchema = mongoose.Schema
  id:
    type: String
    trim: true
    required: true
    index:
      unique: true
      dropDups: true
  titles: [
    type: String
    trim: true
    required: true
  ]
  notesLink:
    type: String
    trim: true
    index:
      unique: true
      dropDups: true
      sparse: true
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
  ]

# Attempts to load the information given in data into the
# current database. Ensures that when loaded, stale data
# is updated but no data is destroyed.
cateModuleSchema.statics.register = register = (data, req) ->
  if data instanceof Array
    return $q.all (register elem, req for elem in data)
  # Can now guarantee data is a single entity
  CateModule.findOne {id: data.id}, (err, module) ->
    if err? then return deferred.reject err
    isFresh = !module?
    module = new CateModule data if isFresh
    module.save (err) ->
      if err? then return deferred.reject err
      if !req then deferred.resolve module
      else
        if module.notesLink?
          Notes.scrape(req, module.notesLink).then (notes) ->
            module.addNotes notes
        deferred.resolve module
  deferred = $q.defer()
  deferred.promise

# Given the url as an index into the module database, will
# add the given notes.
cateModuleSchema.statics.updateModuleNotes = (url, notes) ->
  CateModule.findOne {notesLink: url}, (err, module) ->
    module?.addNotes notes
  
# Adds any given notes to the current module, discards if
# module not found.
# Not vital running procedure, no error checking required.
cateModuleSchema.methods.addNotes = (notes) ->
  console.log 'Add notes'
  for note in notes
    @notes.addUnique note, (a,b) ->
      a.link == b.link
  @save()

CateModule = mongoose.model 'CateModule', cateModuleSchema
module.exports = CateModule

