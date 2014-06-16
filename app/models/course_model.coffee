Schema = (mongoose = require 'mongoose').Schema
ObjectId = Schema.Types.ObjectId

courseSchema = Schema
  # Indexable
  cid: String
  year: Number
  tid:
    index: true, unique: true, type: Number
  # Course info
  name: String
  terms: [Number]
  classes: [String]
  notes: [
    number:
      type: Number, index: true, unique: true
    restype: String
    title: String
    link: String
    time: Number
  ]

courseSchema.index cid: 1, year: -1

formats =
  '1A': ->
    _meta:
      link: "/api/courses/#{@year}/#{@cid}"
    cid: @cid
    name: @name
    terms: @terms
    classes: @classes
    notes:
      _meta: link: "/api/courses/#{year}/#{cid}/notes"
      collection: @notes.map (note) ->
        number: note.number
        restype: note.restype
        title: note.title
        link: note.link
        time: note.time
    exercises:
      _meta: link: "/api/courses/#{@year}/#{@cid}/exercises"

courseSchema.methods.api = (version) ->
  json = formats[version]?.call? @
  if json then json else throw new Error """
  Format #{version} not supported"""

Course = mongoose.model 'Course', courseSchema
module.exports =
  model: Course
  formats: formats
  schema: courseSchema

