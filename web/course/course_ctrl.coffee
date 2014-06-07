classy = angular.module 'classy'

classy.factory 'Courses', (Resource) ->
  class Courses extends Resource({
    actions:
      get: '/api/courses/:year/:mid'
    defaultParams: year: 2013
    relations:
      notes: 'Notes'
      exercises: 'Exercises'
      grades: 'Grades'
      validTo: Date
      validFrom: Date
  })

classy.factory 'Notes', (Resource) ->
  class Notes extends Resource({
    relations:
      time: Date
  })

classy.factory 'Exercises', (Resource) ->
  class Exercises extends Resource({
    relations:
      start: Date
      end: Date
  })

classy.controller 'CourseCtrl', ($scope, $stateParams, Courses) ->
  ($scope.course = Courses.get(mid: $stateParams.mid)).$promise
  .then (course) ->
    console.log course
  .catch (err) ->
    console.log "Error occurred."

