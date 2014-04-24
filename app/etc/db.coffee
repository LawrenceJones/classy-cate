mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
$q = require 'q'
require './model'

# Initial db setup
module.exports = (config) ->

  [name, host, port] = [
    config.mongodb.NAME
    config.mongodb.HOST
    config.mongodb.PORT
  ]
  mongoose.connect config.mongodb.MLAB || "mongodb://#{host}:#{port}/#{name}"

  # Reference connection
  db = mongoose.connection
  db.once 'error', ->
    console.error 'Error connecting to database'
    process.exit 1
  db.once 'open', ->
    console.log 'Database successfully opened!'

  Models = [Exam, Upload, CateModule] = [ # Load database models
    '../exams/exam_model'
    '../uploads/upload_model'
    '../modules/cate_module_model'
  ]
    .map (modelPath) -> (require modelPath)

  # Resets database if RESET_DB env is on
  if process.env.RESET_DB
    rms = Models.map (Model) ->
      Model.remove {}, (err) ->
        if err? then d.reject err else d.resolve()
      (d = $q.defer()).promise
    $q.all rms
      .then ->
        console.log 'Reset Database!'
      .catch (err) ->
        console.error err.toString()
        console.error 'Failed to Reset Database!'

  # If argument is set, intelligently match modules against related
  # exams.
  if process.env.GENERATE_RELATED
    CateModule.generateRelated()


        

      


