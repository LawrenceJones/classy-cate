config = require '../etc/config'
$q = require 'q'
require '../etc/utilities'
# Exam model
Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

examSchema = mongoose.Schema
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
  ]
  classes: [
    type: String
    trim: true
    default: []
  ]
  papers: [ require './past_paper_model' ]
  related: [
    type: ObjectId, ref: 'CateModule', unique: true
    default: [], required: true
  ]
  studentUploads: []

# Takes a single paper object, structured like so...
#
#     { id, title, year, url, classes }
#
# And loads it into the database. If the exam it references
# does not yet exist, then it is created.
#
# Returns a promise that is resolved on successful db save.
examSchema.statics.loadPaper = loadPaper = (paper) ->
  if paper instanceof Array
    return $q.all(paper.map loadPaper)
  exam =
    id: paper.id
    $addToSet:
      titles: paper.title
      papers: year: paper.year, url: paper.url
      classes:
        $each: paper.classes
  update = Exam.findOneAndUpdate\
  ( id: exam.id
  , exam
  , upsert: true, strict: true)
  update.exec (err, exam) ->
    if err?
      console.error err
      return def.reject err
    def.resolve exam
    exam = null
  (def = $q.defer()).promise

# Fills the studentUploads field
examSchema.methods.populateUploads = (login) ->
  exam = this
  def = $q.defer()
  title = @titles[0]
  # Find the general year match
  year  = @id.match(/[1-9]/)?[0] || 'NON'
  query = mongoose
    .model('Upload')
    .find {}
    .populate 'exam'
  query.exec (err, uploads) =>
    @studentUploads = uploads
      .filter (u) -> u
      .filter (u) ->
        return true if u.exam._id == exam._id
        return false if u.exam.id.match(/[1-9]/)?[0] != year
        u.exam.titles.any (t) ->
          keys = t.match(/([A-Z]\w+)/g)
          return false if !keys?
          new RegExp(keys.join('|')).test title
      .map (u) -> u.mask login
    def.resolve @
    def = exam = uploads = null # nullify
  def.promise


# Retrives cate modules that may be associated with the given
# exam id. Looks for id matches against the numerical part of
# the exam id. Exam ID C210, will match against 210 for example.
examSchema.statics.getRelatedModules = (exam) ->
  exam.populate 'related', (err) ->
    ids = exam.id.match /(\d+)/g
    def.resolve exam if ids.length is 0

    rex = "^(#{ids.join('|')})$"
    mongoose.model('CateModule')
      .find { id: $regex:rex }, (err, modules) ->
        exam.related.mergeUnique modules, (a,b) -> a.id == b.id
        if err? then def.reject err
        else def.resolve exam
        def = modules = exam = null # nullify

  (def = $q.defer()).promise

Exam = mongoose.model 'Exam', examSchema
module.exports = Exam
