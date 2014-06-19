auth = angular.module('auth')

auth.factory\
( 'authInterceptor'
, [ '$rootScope', '$q', '$window', '$cacheFactory'
    ($rootScope,   $q,   $window,   $cacheFactory) ->

      request: (config) ->
        config.headers = config.headers || {}
        if $window.localStorage.token
          config.headers.Authorization =
            "Bearer #{$window.localStorage.token}"
        console.log 'CONF', config.headers.Authorization
        return config || $q.when config

      responseError: (response) ->
        if response.status is 401
          console.log 'User is not authed'
          $cacheFactory.get('$http').removeAll()
          if not /login/.test $window.location
            $window.blockedHash ?= $window.location.hash
            $window.location = '#/login' # or whatever login state
        return $q.reject response

])
