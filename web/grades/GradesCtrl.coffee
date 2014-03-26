classy = angular.module 'classy'

classy.factory 'Grades', (CateResource) ->
  class Grades extends CateResource('/api/grades')

classy.controller 'GradesCtrl', ($scope, Grades) ->
  $scope.grades =
    required_modules: []
    optional_modules: []
  Grades.get().then (grades) ->
    $scope.grades = grades

