classy = angular.module 'classy'

classy.factory 'Exercise', (Resource) ->
  class Exercise extends Resource()

classy.factory 'Exercises', (Resource, Module, $rootScope, $q) ->
  class Exercises extends Resource {
    baseurl: '/api/exercises'
    relations: 'modules': Module
  }

classy.controller 'ExercisesCtrl', ($scope, $state, $stateParams, exercises) ->

  $scope.exercises = exercises
  $scope.params = $stateParams

  $scope.changePeriod = (diff) ->
    period = parseInt($stateParams.period, 10) + diff
    if period < 8 && period > 0
      $state.transitionTo 'exercises', {period: period}
