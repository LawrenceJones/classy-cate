auth.directive 'authLogout', (Auth) ->
  restrict: 'AC'
  link: ($scope, $elem, attr) ->
    $elem.click ->
      Auth.logout()

