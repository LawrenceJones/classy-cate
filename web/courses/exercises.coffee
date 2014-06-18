classy = angular.module 'classy'

classy.factory 'Exercises', (Resource, AppState) ->
  class Exercises extends Resource({
    actions:
      get: '/api/courses/:year/:cid/exercises'
    defaultParams:
      year: AppState.currentYear
    relations:
      collection: 'Exercise'
  })

classy.factory 'Exercise', (Resource) ->
  class Exercise extends Resource({
    relations:
      start: Date
      end: Date
      givens: 'Given'
  })

classy.factory 'Given', (Resource) ->
  class Given extends Resource({
    relations:
      time: Date
  })

