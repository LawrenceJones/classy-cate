request = require 'request'
$q = require 'q'

Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

uploadSchema = mongoose.Schema
  name:
    type: String
    trim: true
    required: true
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
    unique: true
  ]
  downvotes: [
    type: String
    trim: true
    unique: true
  ]
  exam:
    type: ObjectId
    ref: 'Exam'

# Masks the identities of the voters, as a simple vote number,
# also marks whether the current user has voted.
uploadSchema.methods.mask = (req) ->
  upload = @toJSON()
  upload.hasVoted = false
  for vote in @upvotes.concat @downvotes
    upload.hasVoted |= (vote == req.user.user)
  upload.upvotes = @upvotes.length
  upload.downvotes = @downvotes.length
  token = req.headers.authorization?.split?(' ')[1]
  upload.url = "/api/uploads/#{@_id}/download?token=#{token}"
  upload

Upload = mongoose.model 'Upload', uploadSchema
module.exports = Upload

