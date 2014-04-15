classy = angular.module 'classy'

classy.directive 'uploadRemoveBtn', (Upload) ->
  restrict: 'AC'
  controller: (Upload, $scope) ->
    $scope.remove = (upload, exam) ->
      removed = upload.remove exam
      removed.then ->
        exam.studentUploads = exam.studentUploads.filter (u) ->
          u.url != upload.url
  template: """
    <a ng-click="remove(upload, exam)"><i class="delete fa fa-trash-o"></i></a>
  """
  scope: upload: '=', exam: '='

classy.directive 'fileUploader', ($http) ->
  restrict: 'E'
  template: """
    <div class="form-group">
      <form>
        <input class="hide" type="file" name="file"/>
      </form>
      <button class="btn btn-lg clicker btn-primary form-control input-lg"
              ng-class="{disabled: !valid}">
        Upload File
      </button>
    </div>"""
  scope: params: '=', url: '@', valid: '=', reqHandler: '='
  link: ($scope, $elem, attr) ->
    $form = $elem.find 'form:eq(0)'
    $input = $elem.find 'input[type=file]'
    $btn = $elem.find 'button.clicker'
    $btn.click -> $input.trigger 'click'
    handleSelect = (evt) ->
      file = evt.target.files[0]
      formData = new FormData()
      formData.append 'upload', file
      urlEncoded = $.param ($scope.params || {})
      req = $http.post "#{$scope.url}?#{urlEncoded}", formData, {
        withCredentials: true
        headers: 'Content-Type': undefined
        transformRequest: angular.identity
      }
      $btn.text 'Loading...'
      req.error (err) ->
        console.error err
        $btn.text 'Upload Failed'
      $scope.reqHandler? req
    $input.on 'change', handleSelect

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
      voted.then (upload) ->
        $scope.upload = upload
  scope: upload: '=', exam: '='
  template: """
    <a class="upvote-arrow" ng-click="vote('up')">
      <i class="fa fa-arrow-up"></i>
    </a>
    <a class="downvote-arrow" ng-click="vote('down')">
      <i class="fa fa-arrow-down"></i>
    </a>
  """

