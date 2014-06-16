auth = angular.module 'auth'
auth.controller\
( 'AuthCtrl'
, [ 'Auth', 'AppState', '$scope', '$http', '$window', '$state'
    (Auth,   AppState,   $scope,   $http,   $window,   $state) ->

      $scope.input =
        user: null
        pass: null

      $scope.denied  = false
      $scope.waiting = false

      $scope.submit = ->
        $scope.waiting = true
        authed = Auth.login $scope.input.user, $scope.input.pass
        authed.then (data) ->
          if $window.blockedHash?
            $window.location = $window.blockedHash
            $window.blockedHash = null
          else
            AppState.user = data.user # load authed user into AppState
            $state.transitionTo 'app.dashboard' # or whatever home
        authed.catch ->
          $scope.denied  = true
          $scope.waiting = false
])

