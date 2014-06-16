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

classy.controller 'ProfileCtrl', ($scope, $rootScope) ->

    # TODO: tidy up, balance properly, consider first years
    profile = $rootScope.user

    $scope.cols = []
    $scope.cols[0] = [ profile.enrolment[0] ]
    $scope.cols[1] = [ profile.enrolment[1] ]

    $rootScope.profile = profile

