classy = angular.module 'classy'

classy.controller 'ExerciseModalCtrl', ($scope, $modalInstance, $stateParams,
                                        TimetableGivens, ex, cid) ->

  $scope.ex = ex
  
  $scope.givens = TimetableGivens.get {
      year: $stateParams.year, cid: cid, num: ex.num
    }

  $scope.cancel = ->
    $modalInstance.dismiss 'cancel'


classy.factory 'TimetableGivens', (Resource, AppState) ->
  class Givens extends Resource({
    actions:
      get: '/api/courses/:year/:cid/exercises/:num/givens'
    defaultParams:
      year: AppState.currentYear
  })
