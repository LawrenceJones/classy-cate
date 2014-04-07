mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
$q = require 'q'

# Initial db setup
module.exports = (config, reset) ->

  [name, host, port] = [
    config.mongodb.NAME
    config.mongodb.HOST
    config.mongodb.PORT
  ]
  mongoose.connect config.mongodb.MLAB || "mongodb://#{host}:#{port}/#{name}"

  # Reference connection
  db = mongoose.connection
  db.on 'error', ->
    console.error 'Error connecting to database'
    process.exit 1
  db.once 'open', ->
    console.log 'Database successfully opened!'
 
  [Exam] = [ # Load database models
    './exams/exam_model'
  ]
    .map (modelPath) -> (require modelPath)
    .map (Model) ->
      Model.remove {}, (err) ->
        if err? then console.error err
