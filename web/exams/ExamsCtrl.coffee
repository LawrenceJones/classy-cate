classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, myexams, modules) ->
  $scope.modules = modules
  $scope.exams = exams
  $scope.myexams = myexams

