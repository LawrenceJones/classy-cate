grepdoc = angular.module 'grepdoc'

grepdoc.factory 'Timetable', (Resource, AppState) ->
  class Timetable extends Resource({
    actions:
      get: '/api/timetable/:year/:period'
    defaultParams:
      year: AppState.currentYear
      period: AppState.currentPeriod
    relations:
      start: Date
      end: Date
      courses: 'TimetableCourse'
  })

grepdoc.factory 'TimetableCourse', (Resource) ->
  class TimetableCourse extends Resource({
    relations: exercises: 'Exercise'
  })

grepdoc.controller 'TimetableCtrl', ($scope, $stateParams, $state, $modal,
                    Timetable, CourseFormatter, PeriodFormatter) ->

  (timetable = Timetable.get($stateParams)).$promise
  .then (course) ->

    $scope.periodRange = PeriodFormatter timetable.start, timetable.end
    $scope.courses = CourseFormatter timetable
    $scope.choosePeriod = (period) ->
      $state.go 'app.timetable', {period: period}
    
    $scope.periodTitle =
      (
        1: 'Autumn Term'
        3: 'Spring Term'
        5: 'Summer Term'
      )[timetable.period]

    $scope.open = (box) ->
      if box.ex? then $modal.open
        templateUrl: '/partials/exercise_modal.html'
        controller: 'ExerciseModalCtrl'
        resolve:
          ex: -> box.ex
          cid: -> box.options.cid
    
