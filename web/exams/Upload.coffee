classy = angular.module 'classy'

classy.factory 'Upload', ($http, $q) ->

  # Directs program flow appropriately to promise results
  handleRequest = (req, deferred = $q.defer()) ->
    req.success (data) ->
      if data.error?
        console.error data
        return deferred.reject data
      deferred.resolve data
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
      if !/^http(s)?:\/\//.test @url
        @url = "http://#{@url}"

    score: ->
      @upvotes - @downvotes

    # Shallow check of name presence.
    hasValidName: ->
      @name? && !/^[\s\t\r\b]*$/.test @name

    # Will save the Uploaded document to an exam.
    save: (examId) ->
      handleRequest $http({
        method: 'POST'
        url: "/api/exams/#{examId}/upload"
        params: name: @name, url: @url
      })

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


