classy = angular.module 'classy'

classy.factory 'Exercise', (Resource) ->
  class Exercise extends Resource {
    parser: ->
      @start = new Date(@start)
      @end = new Date(@end)
      if !@name? or /^[\s\t\r\b\n]*$/.test @name
        @name = 'UNNAMED'
  }

classy.factory 'Exercises', (Resource, Module, $rootScope, $q) ->

  class Exercises extends Resource({
    baseurl: '/api/exercises'
    relations: modules: Module
    parser: ->
      @start = new Date(@start)
      @end = new Date(@end)
  })

    # Maps the $stateParams keys to AppState
    @initParams: ($stateParams) ->
      super $stateParams,
        class:  'currentClass'
        period: 'currentPeriod'
        year:   'currentYear'
        user:   'currentUser'


classy.controller 'ExercisesCtrl', ($scope, $state, $stateParams, exercises) ->

  $scope.exercises = exercises
  $scope.params = $stateParams

  $scope.changePeriod = (diff) ->
    period = parseInt($stateParams.period, 10) + diff
    if period < 8 && period > 0
      $state.transitionTo 'app.exercises', period: period
