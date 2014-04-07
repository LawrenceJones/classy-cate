classy = angular.module 'classy'

classy.controller 'PaperCtrl', ($scope, Exams) ->

  $scope.input =
    mineonly: false
  $scope.input.mineonly = true
  
  $scope.firstFew = (exam, cut) ->
    exam.papers[0..cut]
  $scope.lastFew = (exam, cut) ->
    exam.papers[(cut+1)..]
  $scope.mine = (exam) ->
    if not $scope.input.mineonly then return true
    Exams.isMyExam exam.id





