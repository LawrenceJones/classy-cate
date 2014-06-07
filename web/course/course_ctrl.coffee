classy = angular.module 'classy'

classy.factory 'Courses', (Resource) ->
  class Courses extends Resource({
    actions:
      get: '/api/courses/:year/:mid'
    defaultParams: year: 2013
    parser: ->
      if @validTo && @validFrom
        @validTo = new Date @validTo
        @validFrom = new Date @validFrom
    relations:
      notes: 'Notes'
  })

classy.factory 'Notes', (Resource) ->
  class Notes extends Resource({
    parser: ->
      @time = new Date @time
  })

classy.controller 'CourseCtrl', ($scope, $stateParams, Courses) ->
  ($scope.course = Courses.get(mid: $stateParams.mid)).$promise
    .then (course) ->
      console.log course
  


