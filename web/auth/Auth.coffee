#///////////////////////////////////////////////////////////////////////
# Auth.coffee
#///////////////////////////////////////////////////////////////////////

auth = angular.module 'auth'
auth.factory 'Auth', ($q, $http, $window, $state) ->

  deferred = null

  class Auth

    @user = null

    @isMe: (user) ->
      user?._id == @user?._id

    @whoami: (force) ->
      if !deferred? or force
        deferred = $q.defer()
        if !force and @user? then deferred.resolve @user
        else
          req = $http({
            url: '/api/whoami'
            cache: false  # must be for force
          })
          req
            .success (data, status) ->
              deferred.resolve (Auth.user = JSON.parse data)
            .error (data) -> Auth.user = null
      deferred.promise

    @login: (user, pass) ->
      deferred = $q.defer()
      $http
        .post '/authenticate', {user: user, pass: pass}
        .success (data, status) ->
          console.log 'Success: Authenticated'
          $window.localStorage.token = data.token
          Auth.user = data.user
          deferred.resolve data
        .error (data, status) ->
          console.log 'Error: Invalid user/pass'
          delete $window.localStorage.token
          Auth.user = null
          deferred.reject null
      return deferred.promise

    @logout: ->
      deferred = $q.defer()
      delete $window.localStorage.token
      Auth.user = null
      tapped = Auth.whoami true
      tapped.then (id) -> deferred.resolve id
      deferred.promise

