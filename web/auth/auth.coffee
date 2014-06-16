auth = angular.module 'auth'
auth.factory\
( 'Auth'
, [ '$q', '$http', '$window', '$state'
    ($q, $http, $window, $state) ->

      deferred = null

      class Auth

        @user = null

        @isMe: (user) ->
          user?.is @user # or whatever custom equality

        @whoami: (force) ->
          return deferred.promise if deferred? and !force
          deferred = $q.defer()
          if !force and @user? then deferred.resolve @user
          else $http({
              url: '/api/whoami' # identity route on server
              cache: false  # must be for force
            })\
              .success (data, status) ->
                deferred.resolve (Auth.user = JSON.parse data)
              .error (data) ->
                deferred.reject  (Auth.user = null)
          deferred.promise

        @login: (user, pass) ->
          deferred = $q.defer()
          $http
            .post '/authenticate', user: user, pass: pass
            .success (data, status) ->
              console.log 'Success: Authenticated'
              $window.localStorage.token = data.token
              Auth.user = data.user
              deferred.resolve data
            .error (data, status) ->
              console.log 'Error: Invalid user/pass'
              delete $window.localStorage.token
              deferred.reject (Auth.user = null)
          return deferred.promise

        @logout: ->
          delete $window.localStorage.token
          Auth.user = null
          Auth.whoami true # force whoami
         
])
