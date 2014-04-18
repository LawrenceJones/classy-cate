classy = angular.module 'classy'

classy.factory 'Grades', (Resource, $rootScope) ->
  class Grades extends Resource(baseurl: '/api/grades')
    @query: (query = {}) ->
      query.year ?=  $rootScope.AppState.currentYear
      query.class ?= $rootScope.AppState.currentClass
      query.user ?=  $rootScope.AppState.currentUser
      super query

classy.controller 'GradesCtrl', ($scope, grades) ->
  $scope.grades = grades

