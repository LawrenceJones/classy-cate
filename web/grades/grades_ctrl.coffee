classy = angular.module 'classy'

classy.factory 'Grades', (Resource) ->
  class Grades extends Resource({
    actions:
      all: '/api/grades'
    defaultParams: year: 2013
  })

classy.controller 'GradesCtrl', ($scope, Grades) ->
  $scope.grades = Grades.all()
  .$promise.then (grades) ->
    console.log grades

