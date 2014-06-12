classy = angular.module 'classy'

classy.controller 'TimeTravelCtrl', ($scope) ->
  $scope.gotoYear = (year) ->
    console.log "Going to year #{year}"

classy.directive 'timeTravel', ->
  restrict: 'A'
  templateUrl: '/partials/directives/time_travel'
  replace: true
