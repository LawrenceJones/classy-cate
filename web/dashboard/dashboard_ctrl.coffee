classy = angular.module 'classy'

classy.controller 'DashboardCtrl', ($scope, AppState) ->
  $scope.currentYear = AppState.currentYear
  $scope.currentPeriod = AppState.currentPeriod
  $scope.currentTerm = AppState.currentTerm
  $scope.user = AppState.user

