request = require 'request'
mongoose = require 'mongoose'
express = require 'express'
bodyParser = require 'body-parser'

# Gridfs libraries
fs = require 'fs'
Grid = require 'gridfs-stream'
gfs = Grid mongoose.connection.db, mongoose.mongo

# Cate resources
Exam = mongoose.model 'Exam'
Upload = mongoose.model 'Upload'

module.exports = (app) ->

  # Create upload
  app.post '/api/exams/:id/upload', bodyParser(), routes.submitUpload
  # Vote on upload
  app.post '/api/uploads/:id/:vote(up|down)', routes.vote
  # Download an uploaded file
  app.get '/api/uploads/:id/download', routes.downloadFile
  # Delete an uploaded file
  app.delete '/api/uploads/:id', routes.removeUpload

# Handle for retrieving the login from the request handle. This
# only accesses and returns a login, no passwords are ever exposed.
getLogin = (user) ->
  user('USER_CREDENTIALS').user

routes =

  # POST /api/exams/:id/upload
  # May receive either a data blob, or url.
  submitUpload: (req, res) ->
    Exam.findOne {id: req.params.id}, (err, exam) ->
      if err? or !exam? then return res.send (err? && 500) || 404

      handleSave = (err, upload) ->
        if err? and err.code is 11000
          console.error err
          return res.json error: 'duplicateUrl'
        else if err
          console.error err
          return res.json error: err
        # Once again, requires login for a mask.
        res.json upload.mask getLogin req.user

      upload = new Upload req.query
      upload.upvotes = upload.downvotes = []

      # Signing the upload with the current users login
      # User password is not used, nor made accessible.
      upload.author = getLogin req.user
      upload.exam = exam
      upload.url = req.query.url

      if (file = req.files.upload)?
        ws = gfs.createWriteStream
          _id: upload._id
        fs.createReadStream(file.path).pipe ws
        ws.once 'error', (err) ->
          console.error err.toString()
        ws.once 'close', ->
          upload.save handleSave
      else
        upload.save handleSave

  # GET /api/uploads/:id/download
  downloadFile: (req, res) ->
    Upload
      .findOne _id: req.params.id
      .exec (err, upload) ->
        if err? then return res.send 500
        rs = gfs.createReadStream
          _id: upload._id
        rs.pipe res
        rs.on 'error', (err) ->
          console.error err
          res.send 500


  # DELETE /api/uploads/:id
  # If you do not own the upload you are attempting to delete,
  # then this must be banned.
  removeUpload: (req, res) ->
    handleError = (err) ->
      console.error err
      res.send 500
    Upload
      .findOne {_id: req.params.id}
      .exec (err, upload) ->
        if err? then return handleError err
        # Accessed to ensure that the user has permission to delete this
        # upload. Passwords are not accessed, or made available.
        if upload.author != getLogin req.user
          return res.send 403
        upload.remove (err) ->
          if err? then return handleError err
          res.send 204
          gfs.remove {_id: upload._id}, (err) ->
            console.error err.toString() if err?

  # POST /api/uploads/:id/:vote(up|down)
  vote: (req, res) ->
    Upload
      .findOne _id: req.params.id
      .exec (err, upload) ->
        if err?
          console.error err
          return res.send 500
        pool = upload["#{req.params.vote}votes"]
        # Requires user login to sign their upvote. Passwords are
        # not made accessible.
        login = getLogin req.user
        pool.addUnique login
        upload.save (err) ->
          console.error err if err?
          res.json upload.mask login
        

