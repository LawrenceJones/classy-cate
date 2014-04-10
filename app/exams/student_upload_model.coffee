request = require 'request'
$q = require 'q'

Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

uploadSchema = mongoose.Schema
  name:
    type: String
    trim: true
    required: true
  url:
    type: String
    trim: true
    required: true
    index:
      unique: true
      dropDups: true
  uploaded:
    type: Date
    required: true
    default: Date.now
  author:
    type: String
    required: true
    trim: true
  upvotes: [
    type: String
    trim: true
  ]
  exam:
    type: ObjectId
    ref: 'Exam'

# Verifies that the given url is not dead.
uploadSchema.statics.verifyUrl = (url = '') ->
  deferred = $q.defer()
  request url, (err) ->
    if err? then deferred.reject error: 'invalidUrl'
    else deferred.resolve true
  deferred.promise

Upload = mongoose.model 'Upload', uploadSchema
module.exports = Upload

