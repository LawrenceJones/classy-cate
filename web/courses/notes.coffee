grepdoc = angular.module 'grepdoc'

grepdoc.factory 'Notes', (Resource, AppState) ->
  class Notes extends Resource({
    actions:
      get: '/api/courses/:year/:cid/notes'
    defaultParams:
      year: AppState.currentYear
    relations:
      collection: 'Note'
  })

grepdoc.factory 'Note', (Resource) ->
  class Note extends Resource({
    relations: time: Date
  })

