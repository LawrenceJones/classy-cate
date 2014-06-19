grepdoc = angular.module 'grepdoc'

grepdoc.factory 'Users', (Resource) ->
  class User
    constructor: (data) ->
      angular.extend @, data
    fullName: ->
      [@fname, @lname].join " "
    tutorName: ->
      [@tutor?.title, @tutor?.fname, @tutor?.lname].join " "

grepdoc.controller 'ProfileCtrl', ($scope, AppState, Auth) ->

    # TODO: tidy up, balance properly, consider first years
    console.log 'Profile'
    $scope.profile = profile = AppState.user = Auth.user

    $scope.cols = []
    $scope.cols[0] = [ profile.enrolment[0] ]
    $scope.cols[1] = [ profile.enrolment[1] ]

