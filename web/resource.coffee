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
  '$rootScope', ($http, $q, $rootScope) -> (opt) ->

    # Configure options
    baseurl    =  opt.baseurl
    actions    =  opt.actions ?= {}
    relations  =  opt.relations ?= {}
    parser     =  opt.parser
    formatter  =  opt.formatter
    
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
        isArray = _refs instanceof Array# {{{
        refs = (if isArray then _refs else [_refs]).filter (r) ->
          r?
        isData = typeof refs[0] == 'object'
        self = this

        fini = (data) ->
          deferred.resolve (if isArray then data else data[0])
        
        if isData
          allResolved = $q.all refs.map (data) ->
            console.log data
            if res = resCache[data._id] or !baseurl?
              return res.refresh data
            new self(data).promise
        else # not data, looking at ids
          allResolved = @query _id: refs, true

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
        if query._id instanceof Array# {{{
          query._id = query._id.sort (a,b) -> a - b
        req = $http({
          method: 'GET'
          url: urls.all
          cache: cache
          params: query
        })
        req.success (data) =>
          @makeResource(data)
            .then (res) ->
              console.log res
              deferred.resolve res
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

          
    return class Resource extends ResourceInterface
    
      # Do not call new Resource, as this defies the singleton pattern
      constructor: (data) ->
# {{{
        if data instanceof Array
          throw new Error "#{pragma}Resource constructor called on Array"
        if typeof data != 'object'
          throw new Error "#{pragma}Resource constructor called on Array"

        self = this
        self.promise = (self.deferred = $q.defer()).promise
        if @_id or data._id?
          if resCache[data._id]?
            throw new Error "#{pragma}Attempted to 'new' an existing resource"

          resCache[data._id] = self
          self.refresh data
        else # if not yet a valid _id'd resource
          self.deferred.resolve angular.extend self, data# }}}

      # Populates the active child resources
      populate: (deferred) ->
        self = this# {{{
        allResolved = $q.all keys.map (key) ->
          relations[key].makeResource self[key]
        allResolved.then (resolved) ->
          keys.map (key,i) ->
            self[key] = resolved[i]
          parser? self
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
            url: urls.get.replace ':id', @_id
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
        if @_id?
          req = $http({
            method: 'PUT'
            url: urls.save.replace ':id', @_id
            data: if formatter? then formatter? @ else @
          })
        else
          req = $http({
            method: 'POST'
            url: urls.all
            data: {data: self}
          })
        req.success (data) ->
          self.refresh data
            .then (model) -> deferred.resolve model
            .catch (err = 'Failed to create resource') ->
              deferred.reject err
        return deferred.promise# }}}

      # Deletes the resource. @_id is required.
      delete: ->
        deferred = $q.defer()# {{{
        self = this
        if not @_id?
          mssg = 'Attempting to delete an unsaved resource'
          throw Error mssg
          deferred.reject mssg
        else
          req = $http({
            method: 'DELETE'
            url: urls.get.replace ':id', @_id
          })
          req.success (data) ->
            resCache[self._id] = null
            deferred.resolve 'Deleted resource'
          req.error (err) ->
            deferred.reject err
        return deferred.promise
# }}}

        
]
