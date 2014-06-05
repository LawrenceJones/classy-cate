############################################################
# Resource generator
############################################################

module = angular.module 'resource', []
module.factory 'Resource', [
  '$http'
  '$q'
  '$rootScope', ($http, $q, $rootScope) -> (opt = {}) ->

    # Configure options
    baseurl       =  opt.baseurl
    actions       =  opt.actions ?= {}
    relations     =  opt.relations ?= {}
    parser        =  opt.parser
    defaultParams =  opt.defaultParams ?= {}
    
    # Set up a resource cache
    relationKeys = Object.keys relations
    pragma = if baseurl? then '' else "[#{baseurl}] # "

    # Given a route and parameters, will attempt to generate route
    # to resource given params. Will fail if some parameters in route
    # have not been supplied and cannot be found in defaultParams.
    fillParams = (route, params) ->
      keys = (route.match(/:[^/]+/g) ? []).map (k) -> k[1..]
      for key in keys
        value = params[key] ? defaultParams[key]
        if not value? then throw new Error """
        Failed to supply #{key} parameter for route generation"""
        route = route.replace ":#{key}", value
      return route

    # Wraps $http promises into a standard $q promise.
    wrap = (req) ->
      def = $q.defer()
      req.success (data, status) =>
        if typeof data == 'string'
          data = JSON.parse data
        def.resolve (@makeResource data), status
      req.error (data, status) ->
        def.reject data, status
      return def.promise

    class ResourceInterface

      # Entry to create new resource.
      @makeResource: (data) ->
        if data instanceof Array
          data.map (elem) => @makeResource elem
        else new @ data

      # Get index of all resources.
      @all: -> do @query

      # Fetch result of querying resource.
      @query: (query = {}) ->
        wrap.call @, $http
          method: 'GET'
          url: actions.all
          params: query

      # Retrieve a single resource
      @get: (params) ->
        wrap.call @, $http
          method: 'GET'
          url: fillParams actions.get, params

          
    return class Resource extends ResourceInterface
    
      # Creates new Resource by merging empty object with the supplied
      # server data.
      constructor: (data) ->
        angular.extend @, data
        do @populate
        parser?.call @

      # Analyses current resource and will init any field values that
      # are specified as model relations by new'ing their contents.
      populate: ->
        for key in relationKeys
          if typeof @[key] == 'object' and not (@[key] instanceof Resource)
            @[key] = new angular.factory(relations[key]) @[key]
        return this

      # Generates the api route to this resource.
      getResourceRoute: ->
        fillParams url.get, @

      # Attempt to save changes. On response, if not error then merge response
      # back into the record.
      save: ->
        wrap.call super, $http
          method: 'PATCH'
          url: @getResourceRoute()
        .then (data) =>
          angular.extend @, data

      # Deletes the resource.
      delete: ->
        wrap.call super, $http
          method: 'DELETE'
          url: @getResourceRoute()
        
]
