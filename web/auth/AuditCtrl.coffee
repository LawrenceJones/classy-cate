auth = angular.module 'auth'

auth.directive 'hljs', ->
  restrict: 'A'
  scope: src: '&hljs'
  link: ($scope, $elem, attr) ->
    (hl = (src) ->
      $elem.html src
      hljs.highlightBlock $elem[0])($scope.$eval $scope.src)
    $scope.$watch $scope.src, hl


auth.controller 'AuditCtrl', ($scope, hits, $sce) ->

  $scope.hits = hits
  $scope.stage = 0
  $scope.selected = hits[0]

  $scope.select = (hit) ->
    $scope.selected = hit


