classy = angular.module 'classy'

classy.controller 'UploadModalCtrl',
  ($scope, $q, $modalInstance, Upload, exam) ->
    $scope.exam = exam
    $scope.submitType = 'selection'
    $scope.upload =
      name: null
      anonymous: false
      url: null

    $scope.setType = (type) ->
      $scope.submitType = type
    $scope.valid = url: true, name: true, mssg: ''

    $scope.close = ->
      $modalInstance.dismiss 'cancel'

    $scope.submitUrl = (name, url) ->
      req = $scope.exam.submitUrl name, url
      req.finally (data) ->
        $modalInstance.dismiss 'cancel'
      req.catch (err) ->
        console.error err

    $scope.submitHandler = (req) ->
      req.success (upload) ->
        exam.studentUploads.push upload
        exam.populate()
        $modalInstance.dismiss 'cancel'
