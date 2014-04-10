classy = angular.module 'classy'

classy.factory 'Upload', ($http, $q) ->
  class Upload

    constructor: (data) ->
      angular.extend @, data
      @uploaded = new Date data.uploaded
      @timestamp = @uploaded.format()
      @mailto = """
      mailto:#{@author}@ic.ac.uk?
      Subject=\"Cate Upload '#{@name}'\""""
      if !/^http(s)?:\/\//.test @url
        @url = "http://#{@url}"

    # Shallow check of name presence.
    hasValidName: ->
      @name? && !/^[\s\t\r\b]*$/.test @name

    # Will save the Uploaded document to an exam.
    save: (examId) ->
      req = $http({
        method: 'POST'
        url: "/api/exams/#{examId}/upload"
        params: name: @name, url: @url
      })
      (deferred = $q.defer()).promise
      req.success (data) ->
        deferred.resolve data
      req.error (err) ->
        console.error err.toString()
        deferred.reject err
      deferred.promise

    # Attemps to remove this instance from the server.
    remove: ->
      req = $http({
        method: 'DELETE'
        url: "/api/uploads/#{@_id}"
      })
      deferred = $q.defer()
      req.success (data) ->
        if data.error? then return deferred.reject data
        deferred.resolve data
      req.error (err) ->
        deferred.reject err
      deferred.promise

classy.controller 'UploadModalCtrl',
  ($scope, $q, $modalInstance, Upload, exam, $http) ->
    $scope.exam = exam
    $scope.upload =
      name: null
      url: null
      anonymous: false

    $scope.valid = url: true, name: true, mssg: ''

    # Submits the new upload
    $scope.submit = ->

      handleError = (err) ->
        switch err?.error
          when 'duplicateUrl' then $scope.valid.mssg = """
          You have submitted a link that has already been submitted."""
          when 'invalidUrl' then $scope.valid.url = false

      upload = new Upload $scope.upload
      $scope.upload.url = upload.url
      return if !($scope.valid.name = upload.hasValidName())
      saved = upload.save exam.id
      $scope.waiting = true
      saved.then (data) ->
        if data.error? then return handleError data
        $scope.exam.studentUploads.push new Upload(data)
        $modalInstance.dismiss 'close'
      saved.catch handleError
      saved.finally -> $scope.waiting = false

classy.directive 'uploadRemoveBtn', (Upload) ->
  restrict: 'AC'
  controller: (Upload, $scope) ->
    $scope.remove = (upload, exam) ->
      console.log 'Removing!'
      upload = new Upload upload
      removed = upload.remove exam
      removed.then ->
        console.log 'Removed!'
        exam.studentUploads = exam.studentUploads.filter (u) ->
          u.url != upload.url
  template: """
    <a ng-click="remove(upload, exam)"><i class="fa fa-trash-o"></i></a>
  """
  scope: upload: '=', exam: '='
  

classy.directive 'uploadBtn', ($compile, $state) ->
  restrict: 'AC'
  controller: ($scope, $modal) ->
    $scope.open = (exam) ->
      $modal.open
        templateUrl: '/partials/upload_modal'
        controller: 'UploadModalCtrl'
        windowClass: 'upload-modal'
        backdrop: true
        resolve:
          exam: -> exam
  link: ($scope, $elem, attr) ->
    $scope.exam = $scope.$eval attr.exam
  template: """
    <button class="btn btn-primary" ng-click="open(exam)">
      Upload Document
    </button>
  """

