classy = angular.module 'classy'

classy.factory 'Note', (Resource, $q) ->
  class Note extends Resource(baseurl: '/api/notes')

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
            Note.query year: notes.year, code: notes.code
  template: """
    <span> - </span><a ng-click="open(module)">Notes</a>
  """
  link: ($scope, $a, attr) ->
    module = $scope.$eval attr.module
    $a.remove() if !module.getNotesLink()?
      

