classy = angular.module 'classy'

classy.factory 'Note', (Resource, $q) ->
  class Note extends Resource(baseurl: '/api/notes')

classy.controller 'NotesModalCtrl', ($scope, $modalInstance, notes, module) ->
  $scope.notes = notes
  $scope.module = module
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
          module: -> module
          notes: -> Note.get { link: module.notesLink }
  template: """
    <span> - </span><a ng-click="open(module)">Notes</a>
  """
  link: ($scope, $a, attr) ->
    module = $scope.$eval attr.module
    $a.remove() if !module.notesLink?
      

