classy = angular.module 'classy'

classy.factory 'Exams', (CateResource) ->
  class Exams extends CateResource('/api/exams')

classy.controller 'ExamsCtrl', ($scope, Exams) ->
  $scope.exams = []
  Exams.get().then (data) ->
    $scope.exams = data.exams

