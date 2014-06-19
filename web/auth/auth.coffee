auth = angular.module 'auth'
auth.factory\
( 'Auth'
, [ '$q', '$http', '$window', '$state'
    ($q,   $http,   $window,   $state) ->

      class Auth

        # Returns user information for the currently logged in user
        @whoami: (force = false) ->
          Auth.user = undefined if force
          def = $q.defer()
          if not Auth.user?
            $http
              method: 'GET'
              cache: true
              url: '/api/whoami'
            .success (user) -> def.resolve(Auth.user = user)
            .error (err) -> def.reject err
          else def.resolve Auth.user
          def.promise

        # Sets the token value in the windows localStorage. Returns the
        # JSON token string.
        @storeToken: (data, verbose = true) ->
          console.log 'Success: Authenticated' if verbose
          $window.localStorage.token = data

        # Remove the token from windows localStorage. Also clear the user
        # field of Auth.
        @clearToken: (verbose = true) ->
          console.log 'Error: Invalid user/pass' if verbose
          delete $window.localStorage.token
          Auth.user = undefined

        # Given a login and password, will make a request to /authenticate
        # with the credentials. Returns a promise that is resolved with the
        @login: (login, pass, verbose = false) ->
          def = $q.defer()
          req = $http
            method: 'POST', url: '/authenticate'
            data: login: login, pass: pass
          .success (student, status, headers, config) ->
            Auth.storeToken student._meta.token, verbose
            delete student['token']
            def.resolve Auth.user = student
          .error -> def.reject Auth.clearToken verbose
          def.promise

        # Clears the token from windows localStorage and forces a new whoami
        # request, to refresh user.
        @logout: ->
          do @clearToken
          Auth.whoami true # force whoami
         
])
