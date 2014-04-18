$q = require 'q'
config = require '../etc/config'

# Cate proxy/parsing
CateProxy = require '../cate/cate_proxy'
ExamTimetableProxy = new CateProxy(require './exam_timetable_parser')
PastPaperProxy = require './past_paper_proxy'

# Mongoose
mongoose = require 'mongoose'
Exam = mongoose.model 'Exam'
Upload = mongoose.model 'Upload'

module.exports = (app) ->
  app.get '/api/exams', routes.index
  app.get '/api/exams/:id', routes.getOne

# Wrapper round exam method to prevent leakage of request details.
populateUploads = (exam, req) ->

  # Required for the upload mask. Password is not made available.
  login = req.user('USER_CREDENTIALS').user

  if exam instanceof Array
    return $q.all(exam.map (e) -> populateUploads e, req)
  exam.populateUploads login


routes =

  # GET /api/exams
  # Returns all the exams currently held in the database. Also
  # triggers a new scrape of exams.doc. If cache has expired,
  # will force a scrape prior to returning the database contents.
  index: (req, res) ->

    indexDb = ->
      Exam.find({}).populate('related').exec (err, exams) ->
        populated = populateUploads exams, req
        populated.then (exams) ->
          res.json exams

    scraped = PastPaperProxy.scrapeArchives req.user
    if PastPaperProxy.cacheExpired()
      scraped.then indexDb
    else do indexDb
    

  # GET /api/exams/:id
  # Receives an id parameter and returns the exam info from
  # the database table. If cache has expired will update table
  # first.
  getOne: (req, res) ->
    query = Exam
      .findOne id: req.params.id
      .populate 'related'
    query.exec (err, exam) ->
      return res.send 500 if err?
      return res.send 404 if !exam?
      populated = populateUploads exam, req
      populated.then (exam) ->
        res.json exam
      populated.catch (err) ->
        console.error err
        res.send 500

  # POST /api/exams/:id/relate{id: id}
  # Adds a module to the list of related modules for this exam.
  relate: (req, res) ->
    Exam
      .findOne {_id: req.params.id}
      .populate 'related'
      .exec (err, exam) ->
        if err? then return handleError err
        if !exam? then return res.send 404
        CateModule.findOne {id: req.query.id}, (err, module) ->
          if err? then return handleError err
          if !module? then return res.send 404
          exam.related.addUnique module, (a,b) -> a.id == b.id
          exam.save (err) ->
            if err? then return handleError err
            CateExams.populate(req, exam).then (exam) ->
              res.json exam

  # DELETE /api/exams/:id/relate{id: id}
  # Removes the specified related module from the exam, returns
  # an exam record.
  removeRelated: (req, res) ->
    Exam
      .findOne {_id: req.params.id}
      .populate 'related'
      .exec (err, exam) ->
        if err? then return handleError err
        if !exam? then return res.send 404
        exam.related = exam.related.filter (m) ->
          m.id != req.query.id
        exam.save (err) ->
          if err? then return handleError err
          res.json exam
