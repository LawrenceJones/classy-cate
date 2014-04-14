classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, myexams, modules) ->
  $scope.modules = modules
  $scope.exams = exams

  $scope.myexams = myexams.map (exam) ->
    now = new Date
    date = new Date exam.date
    date.setYear now.getFullYear()
    exam.tminus = Math.floor (date - now)/(1000*24*3600)
    exam
