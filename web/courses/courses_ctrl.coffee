classy = angular.module 'classy'

# Filters out any courses in arr that don't run in term
classy.filter 'runsInTerm', ->
  (arr, term) -> arr.filter (course) -> term in course.terms


classy.controller 'CoursesCtrl', ($scope, courses, AppState, Current) ->

  if (year = AppState.currentYear) is Current.academicYear()
    ending = "running this year"
  else
    ending = "which ran in #{year}"

  $scope.courses = courses

  $scope.coursesDescription = "All courses for your class, #{ending}"

