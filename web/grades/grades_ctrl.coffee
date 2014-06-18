classy = angular.module 'classy'

# Represents a module of grades
classy.factory 'Grades', (Resource, AppState) ->
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

# Service for cleaning an array of graded courses. All ungraded exercises
# are first removed, and any remaining courses with no graded exercises are
# removed.
classy.service 'GradesCleaner', ->
  clean: (courses) ->
    (courses.map (course) -> course.clean()).filter (course) -> course?

classy.controller 'GradesCtrl', ($scope, $stateParams, $state, grades) ->

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

  $scope.courses = grades
  $scope.cols    = columnise $scope.courses, 3

