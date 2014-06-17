grepdoc = angular.module 'grepdoc'

grepdoc.factory 'Users', (Resource) ->
  class Users extends Resource({
    actions:
      get: '/api/users/:login'
  })

    fullName: ->
      [@fname, @lname].join " "

    tutorName: ->
      [@tutor?.title, @tutor?.fname, @tutor?.lname].join " "

grepdoc.controller 'ProfileCtrl', ($scope, AppState) ->

    # TODO: tidy up, balance properly, consider first years
    $scope.profile = (profile = AppState.user)

    $scope.cols = []
    $scope.cols[0] = [ profile.enrolment[0] ]
    $scope.cols[1] = [ profile.enrolment[1] ]

