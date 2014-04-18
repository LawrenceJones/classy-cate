classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, examTimetable) ->
  $scope.exams = exams
  $scope.examTimetable = examTimetable
  $scope.myexams = examTimetable.exams

