classy = angular.module 'classy'

classy.controller 'ExamViewCtrl', ($scope, exam) ->
  $scope.exam = exam
  console.log exam

