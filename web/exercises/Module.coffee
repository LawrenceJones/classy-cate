classy = angular.module 'classy'

classy.factory 'Module', (Resource, Exercise, Note, $rootScope) ->
  class Module extends Resource {
    baseurl: '/api/modules'
    relations: exercises: Exercise, notes: Note
  }
    # Returns the notes for the given year
    getNotesLink: (year = $rootScope.AppState.currentYear) ->
      for note in @notes
        return note if "#{note.year}" == "#{year}"

    


