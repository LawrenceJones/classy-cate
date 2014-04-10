classy = angular.module 'classy'

classy.factory 'Module', (Exercise, Note, $http, $q) ->
  class Module
    constructor: (data) ->
      angular.extend @, data
      @exercises = (new Exercise e for e in @exercises || [])
      @notes = (new Note n for n in @notes || [])
    @getAll: ->
      req = $http({
        method: 'GET'
        url: '/api/modules'
      })
      deferred = $q.defer()
      req.success (data) ->
        deferred.resolve data.map (d) -> new Module d
      req.error (err) ->
        console.error err
        deferred.reject err
      deferred.promise

    


