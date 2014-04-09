classy = angular.module 'classy'

classy.factory 'Givens', (CateResource, $q) ->
  class Givens extends CateResource('/api/givens')
    constructor: (data) ->
      super data
      for given in @givens
        if !/http:/.test given.link
          given.link = "https://cate.doc.ic.ac.uk/#{given.link}"
        

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
      

