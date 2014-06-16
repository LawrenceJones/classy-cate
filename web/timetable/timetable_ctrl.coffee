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
      modules: 'Modules'
  })

classy.factory 'Modules', (Resource) ->
  class Modules extends Resource({
    relations:
      exercises: 'Exercises'
  })

classy.controller 'TimetableCtrl', ($scope, $stateParams, Timetable,
                                    CourseFormatter, PeriodFormatter) ->

  (timetable = Timetable.get({})).$promise
  .then (course) ->
    $scope.period = PeriodFormatter timetable.start, timetable.end
    $scope.courses = CourseFormatter timetable
    $scope.isToday =  (date) ->
      date.midnight().getTime() is (new Date(2014, 1, 15).midnight().getTime())


  .catch (err) ->
    console.log err
    
