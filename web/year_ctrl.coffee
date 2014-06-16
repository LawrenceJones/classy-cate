classy = angular.module 'classy'

classy.controller 'YearCtrl', ($scope, $state, AppState) ->
  $scope.availableYears = AppState.availableYears

  $scope.changeYear = (year) ->

    if AppState.currentYear isnt year
      $state.go $state.current.name, year: year

