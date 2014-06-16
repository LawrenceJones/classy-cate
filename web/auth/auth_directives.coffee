auth = angular.module 'auth'
auth.directive\
( 'authLogout'
, ['Auth', (Auth) ->
    restrict: 'AC'
    link: ($scope, $elem, attr) ->
      $elem.click ->
        Auth.logout()
])

