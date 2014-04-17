config = require '../config'
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
  papers: require './past_paper_model'
  related: [
    type: ObjectId, ref: 'CateModule', unique: true
    default: [], required: true
  ]
  studentUploads: []

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
