classy = angular.module 'classy'

classy.controller 'NavCtrl', ($scope, AppState) ->
  $scope.user = AppState.user
  # console.log $scope.user.fname
