# vi: set fdm=marker
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
$q = require 'q'
Models = require '../models'

conn = null

# Initial db setup
module.exports =

  # Allow a single connection per process.
  connect: (config, verbose = false) ->

    # Singleton
    return conn if conn

    [name, host, port] = [
      config.mongodb.NAME
      config.mongodb.HOST
      config.mongodb.PORT
    ]
    uri = "mongodb://#{host}:#{port}/#{name}"
    mongoose.connect uri

    # Reference connection
    db = mongoose.connection
    db.on 'error', ->
      console.error 'Error connecting to database'
    db.once 'open', ->
      console.log 'Database successfully opened!'
    return db
  
