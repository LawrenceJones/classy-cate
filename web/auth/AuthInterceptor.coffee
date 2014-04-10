auth = angular.module('auth')

auth.factory 'authInterceptor', ($rootScope, $q, $window) ->
  request: (config) ->
    config.headers = config.headers || {}
    if $window.sessionStorage.token
      config.headers.Authorization =
        "Bearer #{$window.sessionStorage.token}"
    return config || $q.when config

  responseError: (response) ->
    if response.status is 401
      console.log 'User is not authed'
      if not /login/.test $window.location
        $window.blockedHash ?= $window.location.hash
        $window.location = '#/login'
    return $q.reject response

