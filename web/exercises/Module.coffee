classy = angular.module 'classy'

classy.factory 'Module', (Resource, Exercise, Note) ->
  class Module extends Resource {
    baseurl: '/api/modules'
    relations: exercises: Exercise, notes: Note
  }

    


