classy = angular.module 'classy'

classy.factory 'Upload', ($http, $q, Resource) ->

  class Upload extends Resource {
    baseurl: '/api/uploads'
    parser: ->
      @uploaded = new Date @uploaded
      @timestamp = @uploaded.format()
      @mailto = """
      mailto:#{@author}@ic.ac.uk?
      Subject=\"Cate Upload '#{@name}'\""""
  }

    score: ->
      @upvotes - @downvotes

    # Shallow check of name presence.
    hasValidName: ->
      @name? && !/^[\s\t\r\b]*$/.test @name

    # Attemps to remove this instance from the server.
    remove: ->
      $http({
        method: 'DELETE'
        url: "/api/uploads/#{@_id}"
      })

    # Votes on the instance of Upload.
    vote: (updown) ->
      $http({
        method: 'POST'
        url: "/api/uploads/#{@_id}/#{updown}"
      })
        .success (upload) =>
          @refresh upload



