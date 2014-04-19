classy = angular.module 'classy'

classy.factory 'Note', (Resource, $rootScope) ->
  class Note extends Resource {
    baseurl: '/api/notes'
    parser: ->
      $rootScope.authed.then (AppState) =>
        for note in @links when note.restype == 'url'
          note.link =
            note.link.replace /USER/,  AppState.currentUser
          note.link =
            note.link.replace /CLASS/, AppState.currentClass
  }

classy.controller 'NotesModalCtrl', ($scope, $modalInstance, notesCollection) ->
  $scope.links = notesCollection.links
  $scope.moduleName = notesCollection.moduleName
  $scope.close = ->
    $modalInstance.dismiss 'cancel'

classy.directive 'notesLink', ->
  restrict: 'CA'
  controller: ($scope, $modal, Note) ->
    $scope.open = (module) ->
      $modal.open
        templateUrl: '/partials/notes_modal'
        controller: 'NotesModalCtrl'
        backdrop: true
        resolve:
          notesCollection: ->
            notes = module.getNotesLink()
            Note.query
              year: notes.year
              code: notes.code
              period: notes.period
  template: """
    <span> - </span><a ng-click="open(module)">Notes</a>
  """
  link: ($scope, $a, attr) ->
    module = $scope.$eval attr.module
    $a.remove() if !module.getNotesLink()?
      

