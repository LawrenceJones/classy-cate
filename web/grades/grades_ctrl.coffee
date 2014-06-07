classy = angular.module 'classy'

classy.factory 'Grades', (Resource) ->
  class Grades extends Resource({
    actions:
      get: '/api/grades'
    defaultParams: year: 2013
    parser: ->
      @stats?.subscriptionLastUpdated = \
        new Date @stats.subscriptionLastUpdated
  })

classy.controller 'GradesCtrl', ($scope, Grades) ->
  ($scope.grades = Grades.get()).$promise
    .then (grades) ->
      console.log grades

