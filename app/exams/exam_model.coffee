config = require '../etc/config'
$q = require 'q'
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
    required: true
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

# Creates a new Exam record from a single parsed paper object.
# Returns a promise that will be resolved on a successful save.
examSchema.statics.createFromPaper = (paper, def = $q.defer()) ->
  exam = new Exam
    id: paper.id
    titles: [ paper.title ]
    classes: paper.classes
    papers: [
      year: paper.year, url: paper.url
    ]
  exam.save (err) ->
    throw err if err?
    def.resolve exam
  return def.promise

# Takes a single paper object, structured like so...
#
#     { id, title, year, url, classes }
#
# And loads it into the database. If the exam it references
# does not yet exist, then it is created.
#
# Returns a promise that is resolved on successful db save.
examSchema.statics.loadPaper = (paper) ->
  Exam.find id: paper.id, (err, exam) ->
    if !exam? then Exam.createFromPaper paper, deferred
    else
      exam.titles.addUnique exam.title
      p = year: paper.year, url: paper.url
      exam.papers.addUnique p, (a,b) -> a.year == b.year
      exam.save (err) ->
        throw err if err?
        deferred.resolve exam
  return (deferred = $q.defer()).promise

# Retrives cate modules that may be associated with the given
# exam id. Looks for id matches against the numerical part of
# the exam id. Exam ID C210, will match against 210 for example.
examSchema.statics.getRelatedModules = (exam) ->
  exam.populate 'related', (err) ->
    ids = exam.id.match /(\d+)/g
    deferred.resolve exam if ids.length is 0

    rex = "^(#{ids.join('|')})$"
    mongoose.model('CateModule')
      .find { id: $regex:rex }, (err, modules) ->
        exam.related.mergeUnique modules, (a,b) -> a.id == b.id
        if err? then deferred.reject err
        else deferred.resolve exam

  deferred = $q.defer()
  deferred.promise

Exam = mongoose.model 'Exam', examSchema
module.exports = Exam
