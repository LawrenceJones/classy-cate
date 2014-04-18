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
  # Indexes all the exams in the database
  app.get '/api/exams', routes.index
  # Gets a singular exam from the db
  app.get '/api/exams/:id', routes.getOne
  # Causes a given module to be related to an exam
  app.post '/api/exams/:id/relate', routes.relate
  # Removes an modules relation to an exam
  app.delete '/api/exams/:id/relate', routes.removeRelated
  # Retrives the students exam timetable
  app.get '/api/exam_timetable', routes.getExamTimetable

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

  # GET /api/exam_timetable
  # Returns a collection of exams that the specified user is
  # registered for.
  getExamTimetable: (req, res) ->
    ttPromise = ExamTimetableProxy.makeRequest req.query, req.user
    ttPromise.then (timetable) ->
      res.json timetable
    ttPromise.catch (err) ->
      console.error err
      res.send 500, err.toString()

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
    CateModule.findOne {id: req.query.id}, (err, module) ->
      return res.send 500 if err?
      return res.send 404 if !module?
      update = Exam.findOneAndUpdate\
      ( id: req.params.id
      , $addToSet: related: module
      , strict: true )
        .populate 'related'
      update.exec (err, exam) ->
        return res.send 500 if err?
        return res.send 404 if !exam?
        populated = populateUploads exam, req
        populated.then (exam) ->
          res.json exam
        populated.catch (err) ->
          console.error err
          res.send 500

  # DELETE /api/exams/:id/relate{id: id}
  # Removes the specified related module from the exam, returns
  # an exam record.
  removeRelated: (req, res) ->
    update = Exam.findOneAndUpdate\
    ( id: req.params.id
    , $removeFromSet: related: req.query.id
    , strict: true )
      .populate 'related'
    update.exec (err, exam) ->
      return res.send 500 if err?
      return res.send 404 if !exam?
      populated = populateUploads exam, req
      populated.then (exam) ->
        res.json exam
      populated.catch (err) ->
        console.error err
        res.send 500

