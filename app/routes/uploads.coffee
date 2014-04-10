request = require 'request'
mongoose = require 'mongoose'
Exam = mongoose.model 'Exam'
Upload = mongoose.model 'Upload'

routes =

  # DELETE /api/uploads/:id
  removeUpload: (req, res) ->
    Upload
      .findOne {_id: req.params.id}
      .remove (err) ->
        if err?
          console.error err
          return res.send 500
        res.send 204
      

module.exports = (app) ->
  app.delete '/api/uploads/:id', routes.removeUpload

        
        

