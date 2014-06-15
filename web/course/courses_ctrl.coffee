classy = angular.module 'classy'

# Filters out any courses in arr that don't run in term
classy.filter 'runsInTerm', ->
  (arr, term) -> arr.filter (course) -> term in course.terms


classy.controller 'CoursesCtrl', ($scope, $stateParams, $state, $rootScope, Courses) ->

  ($scope.courses = Courses.all $stateParams).$promise
    .then ((response) -> )
    .catch (err) ->
      # For now, transition to dashboard if 404: TODO
      $state.go 'app.dashboard' if err.status is 404

