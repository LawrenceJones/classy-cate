classy = angular.module 'classy'

# Represents a module of grades
classy.factory 'Grades', (Resource) ->
  class Grades extends Resource({
    actions:
      all: '/api/grades'
    defaultParams: year: 2013
  })

classy.controller 'GradesCtrl', ($scope, grades) ->
  $scope.grades = grades
  console.log grades

  $scope.forCol = (col) ->
    first = col * (perCol = Math.round($scope.grades.length/3))
    $scope.grades[first .. first + perCol]

