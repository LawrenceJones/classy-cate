grepdoc = angular.module 'grepdoc'

grepdoc.directive 'navYearDropdown', ->
  restrict: 'AEC'
  replace: true
  templateUrl: '/partials/directives/nav_year_dropdown.html'
  controller: ($scope, $state, AppState) ->
    $scope.availableYears = AppState.availableYears
    $scope.changeYear = (year) ->
      if AppState.currentYear isnt year
        $state.go $state.current.name, year: year

