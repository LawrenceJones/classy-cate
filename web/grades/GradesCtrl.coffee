classy = angular.module 'classy'

classy.factory 'Grades', (Resource, $rootScope) ->
  class Grades extends Resource(baseurl: '/api/grades')
    # Maps the $stateParams keys to AppState
    @initParams: ($stateParams) ->
      super $stateParams,
        class:  'currentClass'
        year:   'currentYear'
        user:   'currentUser'

classy.controller 'GradesCtrl', ($scope, grades) ->
  console.log 'GradesCtrl'
  $scope.grades = grades

