classy = angular.module 'classy'

classy.factory 'Exam', (CateResource, Module, Upload, $q, $http) ->

  myExams = new Object()

  handleRequest = (req, cast) ->
    deferred = $q.defer()
    req.success (data) ->
      deferred.resolve (if cast then new Exam data else data)
    req.error (err) ->
      deferred.reject err
    deferred.promise

  class Exam extends CateResource('/api/exams')

    # Wrap the related modules in a module class
    constructor: (data) ->
      angular.extend @, data
      @parent = true
      @related = (new Module m for m in @related || [])
      @studentUploads = (new Upload u for u in @studentUploads || [])

    # Gets the exams that the user is timetabled for.
    @getMyExams: ->
      deferred = $q.defer()
      @makeReq('/api/myexams').success (data) =>
        myExams = new Object()
        exams = data.exams
          .map (e) -> myExams[e.id] = true; new Exam e
          .sort (a,b) -> a.id - b.id # important to guarantee sorting
        deferred.resolve exams
      deferred.promise

    # Evalutates whether the given exam id is one the user
    # is timetables to take.
    @isMine: (id) ->
      myExams[id]?

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



