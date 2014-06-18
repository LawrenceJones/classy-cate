classy = angular.module 'classy'

classy.factory 'Timetable', (Resource) ->
  class Timetable extends Resource({
    actions:
      get: '/api/timetable/:year/:period'
    defaultParams:
      year: 2013
      period: 3
    relations:
      start: Date
      end: Date
      courses: 'TimetableCourse'
  })

classy.factory 'TimetableCourse', (Resource) ->
  class TimetableCourse extends Resource({
    relations: exercises: 'Exercise'
  })

classy.controller 'TimetableCtrl', ($scope, $stateParams, Timetable,
                                    CourseFormatter, PeriodFormatter) ->

  (timetable = Timetable.get({})).$promise
  .then (course) ->
    $scope.period = PeriodFormatter timetable.start, timetable.end
    $scope.courses = CourseFormatter timetable

  .catch (err) ->
    console.log err
    
