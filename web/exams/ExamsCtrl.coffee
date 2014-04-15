classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, myexams, modules) ->
  $scope.modules = modules
  $scope.exams = exams

  $scope.myexams = myexams.map (exam) ->
    now = new Date
    date = new Date "#{exam.date}-#{now.getFullYear()}"
    exam.tminus = Math.round (date - now)/(1000*24*3600)
    exam
