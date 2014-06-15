classy = angular.module 'classy'

classy.controller 'YearCtrl', ($scope, $rootScope, $state) ->
  $scope.changeYear = (year) ->

    if $rootScope.AppState.currentYear isnt year
      $state.go $state.current.name, year: year

