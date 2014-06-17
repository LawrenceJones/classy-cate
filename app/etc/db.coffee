# vi: set fdm=marker
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
$q = require 'q'
Models = require '../models'
config = require './config'

# Initial db setup
module.exports =

  connect: (uri) ->

    [name, host, port] = [
      config.mongodb.NAME
      config.mongodb.HOST
      config.mongodb.PORT
    ]
    mongoose.connect uri || "mongodb://#{host}:#{port}/#{name}"

    def = $q.defer()

    # Reference connection
    db = mongoose.connection
    db.on 'error', ->
      def.reject 'Error connecting to database'
    db.once 'open', ->
      def.resolve 'Database successfully opened!'
    def.promise
  
