request = require 'request'
mongoose = require 'mongoose'
Exam = mongoose.model 'Exam'
Upload = mongoose.model 'Upload'

routes =

  # POST /api/exams/:id/upload
  submitUpload: (req, res) ->

    Exam.findOne {id: req.params.id}, (err, exam) ->
      if err? or !exam? then return res.send (err? && 500) || 401
      console.log req.query

      verified = Upload.verifyUrl(req.query.url)
      verified.catch (err) -> res.json err
      verified.then ->
        upload = new Upload req.query
        upload.author = req.user.user
        upload.exam = exam
        upload.save (err) ->
          if err? and err.code is 11000
            return res.json error: 'duplicateUrl'
          else if err
            return res.json error: err
          res.json upload.mask req

  # DELETE /api/uploads/:id
  removeUpload: (req, res) ->
    Upload
      .findOne {_id: req.params.id}
      .remove (err) ->
        if err?
          console.error err
          return res.send 500
        res.send 204

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


module.exports = (app) ->
  app.delete '/api/uploads/:id', routes.removeUpload
  app.post '/api/exams/:id/upload', routes.submitUpload
  app.post '/api/uploads/:id/:vote(up|down)', routes.vote

        
        

