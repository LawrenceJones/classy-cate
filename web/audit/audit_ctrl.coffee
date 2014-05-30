classy = angular.module 'classy'

classy.directive\
( 'hljs'
, [ ->
      restrict: 'A'
      scope: src: '&hljs'
      link: ($scope, $elem, attr) ->
        (hl = (src) ->
          $elem.html src
          hljs.highlightBlock $elem[0])($scope.$eval $scope.src)
        $scope.$watch $scope.src, hl
])


classy.controller\
( 'AuditCtrl'
, [ '$scope', 'hits', ($scope, hits) ->

    $scope.hits = hits
    $scope.stage = 0
    $scope.selected = hits[0]

    $scope.select = (hit) ->
      $scope.selected = hit
])


