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
      exercises: 'Exercises'
      grades: 'Grades'
  })

classy.factory 'Notes', (Resource) ->
  class Notes extends Resource({
    parser: ->
      @time = new Date @time
  })

classy.factory 'Exercises', (Resource) ->
  class Exercises extends Resource({
    parser: ->
      @start = new Date @start
      @end = new Date @end
  })

classy.factory 'Grades', (Resource) ->
  class Grades extends Resource({
    parser: ->
      [@declaration, @extension, @submission] = \
        [@declaration, @extension, @submission].map (ts) ->
          if typeof ts is 'number' then new Date ts
          else null
  })

classy.controller 'CourseCtrl', ($scope, $stateParams, Courses) ->
  ($scope.course = Courses.get(mid: $stateParams.mid)).$promise
    .then (course) ->
      console.log course
    .catch (err) ->
      console.log "Error occurred."

