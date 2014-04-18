classy = angular.module 'classy'

classy.factory 'Exercise', (Resource) ->
  class Exercise extends Resource {
    parser: ->
      @start = new Date(@start)
      @end = new Date(@end)
  }

classy.factory 'Exercises', (Resource, Module, $rootScope, $q) ->

  # Maps the $stateParam keys to AppState
  keyMap =
    class:  'currentClass'
    period: 'currentPeriod'
    year:   'currentYear'
    user:   'currentUser'

  class Exercises extends Resource({
    baseurl: '/api/exercises'
    relations: modules: Module
    parser: ->
      @start = new Date(@start)
      @end = new Date(@end)
  })

    # Modifies the given parameters, returning true if one of the
    # values had to be changed.
    @initParams: ($stateParams) ->
      AppState = $rootScope.AppState
      !Object.keys(keyMap).reduce\
      ( (a, k) ->
          a &&= $stateParams[k]?
          AppState[keyMap[k]] = ($stateParams[k] ?= AppState[keyMap[k]])
          return a
      , true )

classy.controller 'ExercisesCtrl', ($scope, $state, $stateParams, exercises) ->
  console.log 'Ex Ctrl'

  $scope.exercises = exercises
  console.log exercises
  $scope.params = $stateParams

  $scope.changePeriod = (diff) ->
    period = parseInt($stateParams.period, 10) + diff
    if period < 8 && period > 0
      $state.transitionTo 'exercises', {period: period}
