# Useful directives for common cross-feature links, for example a course name
# being clickable, taking to the appropriate course page.

grepdoc = angular.module 'grepdoc'

# Adds a click listener to the element applied to, taking user to course page
# for given course
grepdoc.directive 'courseLink', ($state) ->
  restrict: 'A'
  link: ($scope, $a, attr) ->
    cid = ($scope.$eval attr.courseLink).cid
    $a.on 'click', ->
      $state.transitionTo 'app.courses.view', cid: cid


grepdoc.directive 'examLink', ($state) ->
  restrict: 'A'
  link: ($scope, $a, attr) ->
    eid = ($scope.$eval attr.examLink).eid
    $a.on 'click', ->
      $state.transitionTo 'app.exams.view', eid: eid
