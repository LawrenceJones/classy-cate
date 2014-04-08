config = require '../config'
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
  titles: [
    type: String
    trim: true
    required: true
  ]
  notes: [
    type:
      type: String
      trim: true
    title:
      type: String
      default: 'NA'
      trim: true
    link:
      type: String
      trim: true
      required: true
  ]

CateModule = mongoose.model 'CateModule', cateModuleSchema
module.exports = CateModule
