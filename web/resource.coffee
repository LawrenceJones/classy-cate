classy = angular.module 'classy'
classy.factory 'CateResource', ($q, $http) -> (url) ->

  cached = null

  class CateResource

    constructor: (data) ->
      if cached?
        throw Error 'Should not be recalling constructor'
      angular.extend @, data
      cached = this

    # Simply retrieves data from the given url, cushioned in a promise.
    @makeReq: (url, method = 'GET') ->
      deferred = $q.defer()
      req = $http({
        url: url
        method: method
      })

    # Basic get to retrieve cate resource data.
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


