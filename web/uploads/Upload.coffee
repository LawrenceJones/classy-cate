classy = angular.module 'classy'

classy.factory 'Upload', ($http, $q) ->

  # Directs program flow appropriately to promise results
  handleRequest = (req, deferred = $q.defer()) ->
    req.success (data) ->
      console.log data
      if data.error?
        return deferred.reject data
      if data instanceof Array
        model = new Upload d for d in data
      model ?= new Upload data
      deferred.resolve model
    req.error (err) ->
      console.error err
      deferred.reject err
    deferred.promise

  return class Upload

    constructor: (data) ->
      angular.extend @, data
      @uploaded = new Date data.uploaded
      @timestamp = @uploaded.format()
      @mailto = """
      mailto:#{@author}@ic.ac.uk?
      Subject=\"Cate Upload '#{@name}'\""""

    score: ->
      @upvotes - @downvotes

    # Shallow check of name presence.
    hasValidName: ->
      @name? && !/^[\s\t\r\b]*$/.test @name

    # Attemps to remove this instance from the server.
    remove: ->
      handleRequest $http({
        method: 'DELETE'
        url: "/api/uploads/#{@_id}"
      })

    # Votes on the instance of Upload.
    vote: (updown) ->
      handleRequest $http({
        method: 'POST'
        url: "/api/uploads/#{@_id}/#{updown}"
      })


