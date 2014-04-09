classy = angular.module 'classy'

classy.factory 'Notes', (CateResource, $q) ->
  class Notes extends CateResource('/api/notes')

classy.controller 'NotesModalCtrl', ($scope, $modalInstance, notes, module) ->
  $scope.notes = notes.notes
  $scope.module = module
  console.log arguments
  $scope.close = ->
    $modalInstance.dismiss 'cancel'

classy.directive 'notesLink', ->
  restrict: 'CA'
  controller: ($scope, $modal, Notes) ->
    $scope.open = (module) ->
      $modal.open
        templateUrl: '/partials/notes_modal'
        controller: 'NotesModalCtrl'
        backdrop: true
        resolve:
          module: -> module
          notes: -> Notes.get { link: module.notesLink }
  template: """
    <span> - </span><a ng-click="open(module)">Notes</a>
  """
  link: ($scope, $a, attr) ->
    module = $scope.$eval attr.module
    $a.remove() if !module.notesLink?
      

