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
    $scope.profile = profile = AppState.user = Auth.user

    console.log $scope.profile

    $scope.getClass = (year) ->
      (profile.enrolment.filter (e) ->
        e.year is year)[0].class.toUpperCase()

    
#
grepdoc.filter 'year', ->
  (arr, year) ->
    arr.filter (course) -> year is course.year
