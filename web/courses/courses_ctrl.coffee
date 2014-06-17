grepdoc = angular.module 'grepdoc'

# Filters out any courses in arr that don't run in term
grepdoc.filter 'runsInTerm', ->
  (arr, term) -> arr.filter (course) -> term in course.terms


grepdoc.controller 'CoursesCtrl', ($scope, $stateParams, $state, Courses) ->

  ($scope.courses = Courses.all $stateParams).$promise
    .then ((response) -> )
    .catch (err) ->
      # For now, transition to dashboard if 404: TODO
      $state.go 'app.profile' if err.status is 404

