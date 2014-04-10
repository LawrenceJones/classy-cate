url = require 'url'
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
        console.log upload
        upload.save (err) ->
          if err? and err.code is 11000
            return res.json error: 'duplicateUrl'
          else if err
            return res.json error: err
          res.json upload


module.exports = (app) ->
  app.post '/api/exams/:id/upload', routes.submitUpload

        
        

