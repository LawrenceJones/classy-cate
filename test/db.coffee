mongoose = require 'mongoose'
$q = require 'q'
Models = require 'app/models'
Seeds = require 'test/seeds'

db = mongoose.connect 'mongodb://localhost:27017/grepdoc-test'

# Opens connection to a test database
module.exports =

  db: db

    


