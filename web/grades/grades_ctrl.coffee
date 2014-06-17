grepdoc = angular.module 'grepdoc'

# Represents a module of grades
grepdoc.factory 'Grades', (Resource, AppState) ->
  class Grades extends Resource({
    actions:
      all: '/api/grades/:year'
    defaultParams:
      year: AppState.currentYear
  })
    
    # Removes all ungraded exercises
    clean: ->
      for j in [@exercises.length-1..0]
        if not /^((A[\*+]?)|[B-F])$/.test @exercises[j].grade
          @exercises.splice j, 1
      return @ if @exercises.length > 0

grepdoc.controller 'GradesCtrl', ($scope, Grades, $stateParams, $state) ->

  # Removes ungraded exercises and filters empty courses from given courses
  clean = (courses) ->
    (courses.map (course) -> course.clean()).filter (course) -> course?

  # Sorts courses into numCols (>0) balanced columns, giving a 2D array
  columnise = (courses, numCols) ->

    # Returns the height of the given col
    height = (col) ->
      col.map (course) -> course.exercises.length + 1.5
        .reduce ((a, b) -> a + b), 0

    # Returns the shortest column in the given cols
    shortest = (cols) ->
      cols.reduce (c1, c2) -> if height(c1) < height(c2) then c1 else c2

    courses.sort (c1, c2) -> c2.exercises.length - c1.exercises.length
    cols = ([] for i in [1..numCols])
    (shortest cols).push course for course in courses
    return cols

  Grades.all({ year: $stateParams.year }).$promise
    .then (response) ->
      $scope.courses = clean response.data
      $scope.cols    = columnise $scope.courses, 3

    .catch (err) ->
      # For now, redirect to default grades page if 404: TODO
      $state.go 'app.profile' if err.status is 404

