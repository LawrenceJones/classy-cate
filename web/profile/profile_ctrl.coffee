classy = angular.module 'classy'

classy.factory 'Users', (Resource) ->
  class Users extends Resource({
    actions:
      get: '/api/users/:login'
  })

    fullName: ->
      [@fname, @lname].join " "

    tutorName: ->
      [@tutor?.title, @tutor?.fname, @tutor?.lname].join " "

classy.controller 'ProfileCtrl', ($scope, $rootScope, Users) ->
  ($scope.profile = Users.get(login: "thb12")).$promise
    .then (profile) ->

      profile.enrolment.map (e) ->
        e.courses.map (c) ->
          c.classes = c.classes.map (cl) ->
            cl.toUpperCase()

      $scope.cols = []
      $scope.cols[0] = [ profile.enrolment[0] ]
      $scope.cols[1] = [ profile.enrolment[1] ]

      $rootScope.profile = profile

    .catch (err) ->
      console.log err

