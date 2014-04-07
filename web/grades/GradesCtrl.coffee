classy = angular.module 'classy'

classy.factory 'Grades', (CateResource) ->
  class Grades extends CateResource('/api/grades')

classy.controller 'GradesCtrl', ($scope, grades) ->
  $scope.grades = grades

