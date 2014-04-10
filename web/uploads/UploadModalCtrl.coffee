classy = angular.module 'classy'

classy.controller 'UploadModalCtrl',
  ($scope, $q, $modalInstance, Upload, exam) ->
    $scope.exam = exam
    $scope.upload =
      name: null
      anonymous: false

    $scope.valid = url: true, name: true, mssg: ''

    $scope.close = ->
      $modalInstance.dismiss 'cancel'

    $scope.submitHandler = (req) ->
      req.success (data) ->
        console.log 'Success!'
        exam.studentUploads.push new Upload data
        $modalInstance.dismiss 'cancel'
