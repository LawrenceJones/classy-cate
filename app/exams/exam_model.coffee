config = require '../config'
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
  title:
    type: String
    trim: true
    required: true
  klass:
    type: String
    trim: true
  papers: [
    year:
      type: String
      required: true
    url:
      type: String
      required: true
    modelAnswers: [
      author: String
      url: String
    ]
  ]
  
Exam = mongoose.model 'Exam', examSchema
module.exports = Exam
