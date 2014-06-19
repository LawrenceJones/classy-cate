classy = angular.module 'classy'

# Filters out any courses in arr that don't run in term
classy.filter 'runsInTerm', ->
  (arr, term) -> arr.filter (course) -> term in course.terms


classy.controller 'CoursesCtrl', ($scope, courses) ->

  $scope.courses = courses

