classy = angular.module 'classy'
classy.factory 'CateResource', ($q, $http) -> (url) ->

  cached = null

  class CateResource

    constructor: (data) ->
      if cached?
        throw Error 'Should not be recalling constructor'
      angular.extend @, data
      cached = this

    @get: ->
      deferred = $q.defer()
      self = this
      req = $http({
        method: 'GET'
        url: url
      })
      req.success (data) ->
        if cached?
          angular.extend cached, data
        else cached = new self data
        deferred.resolve cached
      if cached?
        deferred.resolve cached
      deferred.promise


