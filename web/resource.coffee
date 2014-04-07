classy = angular.module 'classy'
classy.factory 'CateResource', ($q, $http) -> (url, key, cache = true) ->

  class CateResource

    constructor: (data) ->
      angular.extend @, data

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
        cache: cache
      })
      req.success (data) ->
        if data instanceof Array
          data = (new self elem for elem in data)
        else data = new self data
        deferred.resolve data
      deferred.promise


