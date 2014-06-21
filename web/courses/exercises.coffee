grepdoc = angular.module 'grepdoc'

grepdoc.factory 'Exercises', (Resource, AppState) ->
  class Exercises extends Resource({
    actions:
      get: '/api/courses/:year/:cid/exercises'
    defaultParams:
      year: AppState.currentYear
    relations:
      collection: 'Exercise'
  })

grepdoc.factory 'Exercise', (Resource) ->
  class Exercise extends Resource({
    relations:
      start: Date
      end: Date
      givens: 'Given'
  })

grepdoc.factory 'Given', (Resource) ->
  class Given extends Resource({
    relations:
      time: Date
  })

