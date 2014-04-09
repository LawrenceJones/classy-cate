classy = angular.module 'classy'

classy.controller 'PaperCtrl', ($scope, Exam) ->

  $scope.input =
    mineonly: false
  $scope.input.mineonly = true
  
  $scope.firstFew = (exam, cut) ->
    if cut is -1 then return []
    exam.papers[0..cut]
  $scope.lastFew = (exam, cut) ->
    exam.papers[(cut+1)..]
  $scope.mine = (exam) ->
    if not $scope.input.mineonly then return true
    Exam.isMyExam exam.id





