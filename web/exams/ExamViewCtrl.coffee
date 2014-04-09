classy = angular.module 'classy'

classy.controller 'ExamViewCtrl', ($scope, exam) ->
  $scope.exam = exam
  console.log 'Exam view ctrl'
  console.log exam

