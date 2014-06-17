grepdoc = angular.module 'grepdoc'

grepdoc.controller 'NavCtrl', ($scope, AppState) ->
  $scope.currentYear = AppState.currentYear
  $scope.user = AppState.user
