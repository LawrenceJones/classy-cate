auth = angular.module 'auth'
auth.controller\
( 'AuthCtrl'
, [ 'Auth', '$scope', '$http', '$window', '$state'
    (Auth, $scope, $http, $window, $state) ->

      $scope.input =
        user: null
        pass: null

      $scope.denied = false
      $scope.btnMssg = ->
        if $scope.denied then 'Invalid, try again' else 'Login'

      $scope.submit = ->
        $scope.waiting = true
        authed = Auth.login $scope.input.user, $scope.input.pass
        authed.then (data) ->
          if $window.blockedHash?
            $window.location = $window.blockedHash
            $window.blockedHash = null
          else $state.transitionTo 'app.dashboard'
        authed.catch ->
          $scope.denied = true
          $scope.waiting = false
])

