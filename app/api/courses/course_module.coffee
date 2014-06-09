Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

courseSchema = mongoose.Schema
  cid: Number
  name: String
  terms: [Number]
  classes: [String]

module.exports = Course = mongoose.model 'Course', courseSchema

