auth = angular.module 'auth'
auth.factory\
( 'Auth'
, [ '$q', '$http', '$window', '$state'
    ($q, $http, $window, $state) ->

      deferred = null

      class Auth

        @user = null

        # Returns user information for the currently logged in user
        @whoami: (force = false) ->
          @user = undefined if force
          $q.fcall =>
            return @user if @user?
            $http.get(url: '/authenticate').success (@user) => @user

        # Sets the token value in the windows localStorage. Returns the
        # JSON token string.
        @storeToken: (data, verbose = true) ->
          console.log 'Success: Authenticated' if verbose
          Auth.user = data.user
          $window.localStorage.token = data.token

        # Remove the token from windows localStorage. Also clear the user
        # field of Auth.
        @clearToken: (verbose = true) ->
          console.log 'Error: Invalid user/pass' if verbose
          delete $window.localStorage.token
          Auth.user = undefined

        # Given a login and password, will make a request to /authenticate
        # with the credentials. Returns a promise that is resolved with the
        @login: (login, pass) ->
          $q.fcall =>
            $http.post '/authenticate', login: login, pass: pass
            .success (data) => @storeToken data
            .error @clearToken

        # Clears the token from windows localStorage and forces a new whoami
        # request, to refresh user.
        @logout: ->
          do @clearToken
          Auth.whoami true # force whoami
         
])
