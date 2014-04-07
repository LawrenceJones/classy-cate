classy = angular.module 'classy'

classy.controller 'PaperCtrl', ($scope) ->
  $scope.firstFew = (exam, cut) ->
    exam.papers[0..cut]
  $scope.lastFew = (exam, cut) ->
    exam.papers[(cut+1)..]



