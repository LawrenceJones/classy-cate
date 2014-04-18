request = require 'request'
mongoose = require 'mongoose'
express = require 'express'

# Gridfs libraries
fs = require 'fs'
Grid = require 'gridfs-stream'
gfs = Grid mongoose.connection.db, mongoose.mongo

# Cate resources
Exam = mongoose.model 'Exam'
Upload = mongoose.model 'Upload'

module.exports = (app) ->

  # Create upload
  app.post '/api/exams/:id/upload', express.bodyParser(), routes.submitUpload
  # Vote on upload
  app.post '/api/uploads/:id/:vote(up|down)', routes.vote
  # Download an uploaded file
  app.get '/api/uploads/:id/download', routes.downloadFile
  # Delete an uploaded file
  app.delete '/api/uploads/:id', routes.removeUpload

routes =

  # POST /api/exams/:id/upload
  # May receive either a data blob, or url.
  submitUpload: (req, res) ->
    Exam.findOne {id: req.params.id}, (err, exam) ->
      if err? or !exam? then return res.send (err? && 500) || 404

      handleSave = (err) ->
        if err? and err.code is 11000
          console.error err
          return res.json error: 'duplicateUrl'
        else if err
          return res.json error: err
        res.json upload.mask req

      upload = new Upload req.query
      upload.upvotes = upload.downvotes = []
      upload.author = req.user.user
      upload.exam = exam
      upload.url = req.query.url

      if (file = req.files.upload)?
        ws = gfs.createWriteStream
          _id: upload._id
        fs.createReadStream(file.path).pipe ws
        ws.on 'error', (err) ->
          console.error err.toString()
        ws.on 'close', ->
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
        if upload.author != req.user.user
          return res.send 403
        upload.remove (err) ->
          if err? then return handleError err
          res.send 204
          gfs.remove {_id: upload._id}, (err) ->
            console.error err.toString() if err?

  # POST /api/uploads/:id/:vote(up|down)
  vote: (req, res) ->
    Upload
      .findOne {_id: req.params.id}
      .exec (err, upload) ->
        if err?
          console.error err
          return res.send 500
        pool = upload["#{req.params.vote}votes"]
        pool.addUnique req.user.user
        upload.save (err) ->
          console.error err if err?
          res.json upload.mask req
        

