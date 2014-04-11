classy = angular.module 'classy'
classy.factory 'CateResource', ($q, $http) -> (url, key, cache = true) ->

  class CateResource

    constructor: (data) ->
      angular.extend @, data

    # Simply retrieves data from the given url, cushioned in a promise.
    @makeReq: (url, method = 'GET', params = {}) ->
      req = $http({
        url: url
        method: method
      })

    # Retrieves a single resource by id.
    @getOneById: (id) ->
      deferred = $q.defer()
      req = @makeReq "#{url}/#{id}"
      req.success (data) =>
        deferred.resolve new @(data)
      req.error (err) ->
        deferred.reject err
      deferred.promise

    # Basic get to retrieve cate resource data.
    @get: (params = {}) ->
      deferred = $q.defer()
      self = this
      req = $http({
        method: 'GET'
        url: url
        params: params
        cache: cache
      })
      req.success (data) ->
        if data instanceof Array
          data = (new self elem for elem in data)
        else data = new self data
        deferred.resolve data
      deferred.promise



