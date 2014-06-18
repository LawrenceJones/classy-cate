classy = angular.module 'classy'

classy.factory 'Notes', (Resource, AppState) ->
  class Notes extends Resource({
    actions:
      get: '/api/courses/:year/:cid/notes'
    defaultParams:
      year: AppState.currentYear
    relations:
      collection: 'Note'
  })

classy.factory 'Note', (Resource) ->
  class Note extends Resource({
    relations: time: Date
  })

