classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, myexams) ->
  $scope.exams = exams
  $scope.myexams = myexams

