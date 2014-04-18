classy = angular.module 'classy'

classy.factory 'MyExams', (Resource) ->
  class MyExams extends Resource(baseurl: '/api/myexams')

classy.factory 'Exam', (Resource, Module, Upload, $q, $http) ->

  myExams = new Object()

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
  }

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



