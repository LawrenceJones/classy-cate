classy = angular.module 'classy'

# Represents a module of grades
classy.factory 'Grades', (Resource) ->
  class Grades extends Resource({
    actions:
      all: '/api/grades'
    defaultParams: year: 2013
  })
    
    # Removes all ungraded exercises
    clean: ->
      for j in [@exercises.length-1..0]
        if not /^((A[\*+]?)|[B-F])$/.test @exercises[j].grade
          @exercises.splice j, 1
      return @


classy.controller 'GradesCtrl', ($scope, Grades) ->

  Grades.all().$promise.then (grades) ->

    # Remove all ungraded exercises and empty courses
    $scope.grades = grades.map (course) -> course.clean()
      .filter (course) -> course.exercises.length > 0

    # Returns the course grade sets for given col
    $scope.forCol = (col) ->
      perCol = $scope.grades.length/3
      first = (c) -> Math.round(c * perCol)
      $scope.grades[(first col) .. ((first (col+1)) - 1)]

