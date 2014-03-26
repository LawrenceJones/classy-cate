auth = angular.module 'auth'
auth.controller 'AuthCtrl', (Auth, $scope, $http, $window, $state) ->

  $scope.input =
    user: null
    pass: null

  $scope.denied = false
  $scope.btnMssg = ->
    if $scope.denied then 'Invalid, try again' else 'Login'

  $scope.submit = ->
    authed = Auth.login $scope.input.user, $scope.input.pass
    authed.then (data) ->
      $state.transitionTo 'bookings'
    authed.catch ->
      $scope.denied = true

