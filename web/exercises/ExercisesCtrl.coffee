classy = angular.module 'classy'

classy.factory 'Exercise', ->
  class Exercise
    constructor: (data) ->
      angular.extend @, data
      @start = new Date @start
      @end = new Date @end

classy.factory 'Module', (Exercise) ->
  class Module
    constructor: (data) ->
      angular.extend @, data
      @exercises = (new Exercise e for e in @exercises)


classy.factory 'Exercises', (CateResource, Module, $q) ->
  class Exercises extends CateResource('/api/exercises')
    constructor: (data) ->
      super data
      @modules = (new Module m for m in @modules)

classy.controller 'ExercisesCtrl', ($scope, $state, $stateParams, exercises) ->
  $scope.exercises = exercises
  console.log exercises

  $scope.changePeriod = (diff) ->
    period = parseInt($stateParams.period, 10) + diff
    console.log period
    if period < 8 && period > 0
      $state.transitionTo 'exercises', {period: period}
