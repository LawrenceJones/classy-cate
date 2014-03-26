classy = angular.module 'classy'
classy.factory 'CateResource', ($q, $http) -> (url) ->
  class CateResource

    constructor: (data) ->
      angular.extend @, data

    @get: ->
      self = this
      deferred = $q.defer()
      req = $http({
        method: 'GET'
        url: url
      })
      req.success (data) ->
        deferred.resolve new self(data)
      deferred.promise


