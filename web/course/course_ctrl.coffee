classy = angular.module 'classy'

classy.factory 'Course', (Resource) ->
  class Course extends Resource({
    actions:
      get: '/api/courses/:year/:mid'
    defaultParams: year: 2013
    parser: ->
      @validFrom = new Date @validFrom
      @validTo = new Date @validTo
  })


classy.controller 'CourseCtrl', ($scope, $stateParams, Course) ->

  Course.get(mid: $stateParams.mid).then (course) ->
    console.log course
    $scope.course = course


