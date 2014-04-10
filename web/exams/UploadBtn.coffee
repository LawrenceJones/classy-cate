classy = angular.module 'classy'

classy.controller 'UploadModalCtrl',
  ($scope, $q, $modalInstance, Upload, exam, $http) ->
    $scope.exam = exam
    $scope.upload =
      name: null
      url: null
      anonymous: false

    $scope.valid = url: true, name: true, mssg: ''

    $scope.close = ->
      $modalInstance.dismiss 'cancel'

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
      removed = upload.remove exam
      removed.then ->
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

classy.directive 'uploadUpvoteBtns', ($compile, $state) ->
  restrict: 'AC'
  controller: ($scope, Upload) ->
    $scope.vote = (updown) ->
      $scope.upload = new Upload $scope.upload
      voted = $scope.upload.vote updown
      voted.then (data) ->
        $scope.upload = new Upload data
  scope: upload: '=', exam: '='
  template: """
    <a class="upvote-arrow" ng-click="vote('up')">
      <i class="fa fa-arrow-up"></i>
    </a>
    <a class="downvote-arrow" ng-click="vote('down')">
      <i class="fa fa-arrow-down"></i>
    </a>
  """

