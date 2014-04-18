classy = angular.module 'classy'

classy.factory 'Module', (Resource, Exercise, Note) ->
  class Module extends Resource {
    relations: exercises: Exercise, notes: Note
  }

    


