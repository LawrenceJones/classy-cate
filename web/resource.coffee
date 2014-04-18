################################################################################
# Resource generator
################################################################################

# Potentially required for a delete
extendReplace = (dest, source) ->
  for own k,v of dest
    if not source[k]? then delete dest[k]
  angular.extend dest, source

module = angular.module('resource')
module.factory 'Resource', [
  '$http'
  '$q'
  '$rootScope', ($http, $q, $rootScope) -> (opt = {}) ->

    # Configure options
    baseurl    =  opt.baseurl
    actions    =  opt.actions ?= {}
    relations  =  opt.relations ?= {}
    parser     =  opt.parser
    formatter  =  opt.formatter
    uniqueKey  =  opt.uniqueKey
    
    # Set up a resource cache
    resCache = {}
    keys = Object.keys relations
    pragma = if baseurl? then '' else "[#{baseurl}] # "

    # Set default url or any given in actions
    if baseurl? then urls = angular.extend {
      all:     "#{baseurl}"
      query:   "#{baseurl}"
      create:  "#{baseurl}"
      get:     "#{baseurl}/:id"
      save:    "#{baseurl}/:id"
      remove:  "#{baseurl}/:id"
    }, actions

    class ResourceInterface

      # Takes either a data object ready to be initialised, or an object
      # id, with which to perform a get.
      # Both these options could come as a singular item or inside arrays.
      # Ids...
      #     1 || [ 1, 2... ]
      # Data...
      #     Res || [ Res, Res... ]
      @makeResource: (_refs) ->

        # Determine type of input, array or object
        isArray = _refs instanceof Array# {{{
        refs = (if isArray then _refs else [_refs]).filter (r) ->
          r?
        isData = typeof refs[0] == 'object'

        # If an empty array then just return
        if refs.length is 0
          def = $q.defer()
          def.resolve []
          return def.promise

        fini = (data) ->
          deferred.resolve (if isArray then data else data[0])
        
        if isData
          allResolved = $q.all refs.map (data) =>
            if uniqueKey? and (id = data[uniqueKey])? and (res = resCache[id])
              return res.refresh data
            new @(data).promise
        else # not data, looking at ids
          # TODO - Not currently supported
          allResolved = @query id: refs, true

        allResolved.then fini
        (deferred = $q.defer()).promise# }}}

      # Fetch all resources
      @all: ->
        deferred = $q.defer()# {{{
        req = $http({
          method: 'GET'
          url: urls.all
        })
        req.success (data) =>
          @makeResource(data).then (res) ->
            deferred.resolve res
        return deferred.promise
# }}}

      # Fetch queries resources
      @query: (query = {}, cache = true) ->
        if query.id instanceof Array# {{{
          query.id = query.id.sort (a,b) -> a - b
        req = $http({
          method: 'GET'
          url: urls.all
          cache: cache
          params: query
        })
        req.success (data) =>
          @makeResource(data)
            .then (res) ->
              deferred.resolve res
            .catch (err) ->
              console.error err
        (deferred = $q.defer()).promise# }}}
       

      # Retrieve a single resource
      @get: (id, cache) ->
        deferred = $q.defer()# {{{
        req = $http({
          method: 'GET'
          url: urls.get.replace ':id', id
        })
        req.success (data) =>
          @makeResource(data).then (res) ->
            deferred.resolve res
        return deferred.promise# }}}

      # Modifies the given parameters, returning true if one of the
      # values had to be changed.
      @initParams: ($stateParams, keyMap) ->
        AppState = $rootScope.AppState
        !Object.keys(keyMap).reduce\
        ( (a, k) ->
            a &&= $stateParams[k]?
            AppState[keyMap[k]] = ($stateParams[k] ?= AppState[keyMap[k]])
            return a
        , true )

          
    return class Resource extends ResourceInterface
    
      # Do not call new Resource, as this defies the singleton pattern
      constructor: (data) ->
# {{{
        if data instanceof Array
          throw new Error "#{pragma}Resource constructor called on Array"
        if typeof data != 'object'
          throw new Error "#{pragma}Resource constructor called on Scalar"

        self = this
        self.promise = (self.deferred = $q.defer()).promise
        if uniqueKey? and (identifier = @[uniqueKey])?
          if resCache[identifier]?
            throw new Error "#{pragma}Attempted to 'new' an existing resource"

          resCache[identifier] = self
          self.refresh data
        else # if not yet a valid id'd resource
          angular.extend self, data
          self.populate self.deferred# }}}

      # Populates the active child resources
      populate: (deferred) ->
        self = this# {{{
        allResolved = $q.all keys.map (key) ->
          relations[key].makeResource self[key]
        allResolved.then (resolved) ->
          keys.map (key,i) ->
            self[key] = resolved[i]
          parser?.call? self
          self.deferred.resolve self
        return self.promise# }}}
      
      # Polls the server for updated information
      refresh: (data) ->
        recurse = (data) -># {{{
          angular.extend self, data
          self.populate()

        self = this
        if data? then recurse data
        else
          req = $http({
            method: 'GET'
            url: urls.get.replace ':id', @[uniqueKey]
            cache: false
          })
            .success recurse
            .error (data) ->
              console.log "#{pragma}Error fetching content"
              self.deferred.reject data
        return self.promise# }}}
          
      # Attempt to save changes, if no id then attempt creation
      save: ->
        deferred = $q.defer()# {{{
        self = this
        if uniqueKey? and (identifier = @[uniqueKey])?
          req = $http({
            method: 'PUT'
            url: urls.save.replace ':id', identifer
            data: if formatter? then formatter? @ else @
          })
        else
          req = $http({
            method: 'POST'
            url: urls.all
            data: data: self
          })
        req.success (data) ->
          self.refresh data
            .then (model) -> deferred.resolve model
            .catch (err = 'Failed to create resource') ->
              deferred.reject err
        return deferred.promise# }}}

      # Deletes the resource. @id is required.
      delete: ->
        deferred = $q.defer()# {{{
        self = this
        if not uniqueKey? or (identifier = @[uniqueKey])?
          mssg = 'Attempting to delete an unsaved resource'
          throw Error mssg
          deferred.reject mssg
        else
          req = $http({
            method: 'DELETE'
            url: urls.get.replace ':id', identifier
          })
          req.success (data) ->
            resCache[identifier] = null
            deferred.resolve 'Deleted resource'
          req.error (err) ->
            deferred.reject err
        return deferred.promise
# }}}

        
]
