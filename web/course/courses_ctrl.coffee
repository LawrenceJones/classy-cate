classy = angular.module 'classy'

# Filters out any courses in arr that don't run in term
classy.filter 'runsInTerm', ->
  (arr, term) -> arr.filter (course) -> term in course.terms


classy.controller 'CoursesCtrl', ($scope, $stateParams, $state,
                                  Courses, FormattingService) ->

  ($scope.courses = Courses.all $stateParams).$promise
    .then (response) ->

      $scope.termsStr   = FormattingService.termsArrayToString
      $scope.coursesStr = FormattingService.courseArrayToString

    .catch (err) ->
      # For now, transition to default courses index if 404: TODO
      $state.transitionTo 'app.courses' if err.status is 404

