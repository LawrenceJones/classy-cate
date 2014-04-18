classy = angular.module 'classy'

classy.factory 'ExamTimetable', (Resource, Exam, $rootScope) ->
  class ExamTimetable extends Resource {
    baseurl: '/api/exam_timetable'
    parser: ->
      Exam.myExams ?= {}
      for exam in @exams
        (Exam.myExams[$rootScope.AppState.currentUser] ?= {})[exam.id] = @
        exam.datetime = new Date exam.datetime
        exam.tminus = Math.round (exam.datetime - Date.now())/(1000*60*60*24)
  }

classy.factory 'Exam', (Resource, Module, Upload, $rootScope, $q, $http) ->

  handleRequest = (req, cast) ->
    deferred = $q.defer()
    req.success (data) ->
      deferred.resolve (if cast then new Exam data else data)
    req.error (err) ->
      deferred.reject err
    deferred.promise

  class Exam extends Resource {
    baseurl: '/api/exams'
    relations: 'related': Module, 'studentUploads': Upload
    parser: ->
      @papers = @papers.sort (a,b) -> b.year - a.year
  }

    # Contains all the exams the current student is timetabled for.
    @myExams: new Object()

    # Returns true if an exam id is one the current student is
    # timetabled for.
    @isMine: (id) ->
      Exam.myExams[$rootScope.AppState.currentUser][id]?

    # Pick latest title as default
    title: (full) ->
      t = @titles[0]
      if full then "#{@id}: #{t}" else t

    # Lists other titles
    otherTitles: ->
      @titles[1..].join ', '

    # Relate a module with this exam
    relateModule: (module) ->
      handleRequest $http({
        method: 'POST'
        url: "/api/exams/#{@_id}/relate"
        params: id: module.id
      })

    # Removes a module linked to the Exam
    removeModule: (module) ->
      handleRequest $http({
        method: 'DELETE'
        url: "/api/exams/#{@_id}/relate"
        params: id: module.id
      })

    # Submits a new url upload
    submitUrl: (name, url) ->
      handleRequest $http({
        method: 'POST'
        url: "/api/exams/#{@id}/upload"
        params: name: name, url: url
      }), false



