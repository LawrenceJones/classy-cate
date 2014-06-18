classy = angular.module 'classy'

classy.factory 'Timetable', (Resource, AppState) ->
  class Timetable extends Resource({
    actions:
      get: '/api/timetable/:year/:period'
    defaultParams:
      year: AppState.currentYear
      period: AppState.currentPeriod
    relations:
      start: Date
      end: Date
      courses: 'Courses'
  })

classy.controller 'TimetableCtrl', ($scope, $stateParams, $modal,
                    Timetable, CourseFormatter, PeriodFormatter) ->

  (timetable = Timetable.get($stateParams)).$promise
  .then (course) ->
    $scope.period = PeriodFormatter timetable.start, timetable.end
    $scope.courses = CourseFormatter timetable
    
    $scope.open = (box) ->
      if box.ex?
        $modal.open {
          templateUrl: '/partials/exercise_modal'
          controller: 'ExerciseModalCtrl'
          resolve:
            ex: -> box.ex
            cid: -> box.options.cid
        }

  .catch (err) ->
    console.log err
    
