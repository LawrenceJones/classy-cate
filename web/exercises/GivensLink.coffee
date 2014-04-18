classy = angular.module 'classy'

classy.factory 'Givens', (Resource, $q) ->
  class Givens extends Resource(baseurl: '/api/givens')
        

classy.controller 'GivensModalCtrl', ($scope, $modalInstance, ex, givens) ->
  $scope.givens = givens
  $scope.exercise = ex
  $scope.close = ->
    $modalInstance.dismiss 'cancel'

classy.directive 'givensLink', ->
  restrict: 'CA'
  controller: ($scope, $modal, Givens) ->
    $scope.open = (exercise) ->
      $modal.open
        templateUrl: '/partials/givens_modal'
        controller: 'GivensModalCtrl'
        backdrop: true
        resolve:
          ex: -> exercise
          givens: -> Givens.get { link: exercise.givens }
  template: """
    <a ng-click="open(exercise)">Givens</a>
  """
  link: ($scope, $a, attr) ->
    $scope.exercise = $scope.$eval attr.exercise
    $a.remove() if !$scope.exercise.givens?
      

