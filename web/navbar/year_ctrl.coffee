grepdoc = angular.module 'grepdoc'

grepdoc.controller 'navYearDropdown', ->
  restrict: 'AE'
  templateUrl: '/partials/directives/nav_year_dropdown'
  controller: ($scope, $state, AppState) ->
    $scope.availableYears = AppState.availableYears
    $scope.changeYear = (year) ->
      if AppState.currentYear isnt year
        $state.go $state.current.name, year: year

