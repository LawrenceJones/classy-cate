classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, myexams, modules) ->
  $scope.modules = modules
  console.log modules
  $scope.exams = exams
  $scope.myexams = myexams

