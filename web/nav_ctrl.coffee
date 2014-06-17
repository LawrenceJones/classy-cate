classy = angular.module 'classy'

classy.controller 'NavCtrl', ($scope, AppState) ->
  $scope.currentYear = AppState.currentYear
  $scope.user = AppState.user
