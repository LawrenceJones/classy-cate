classy = angular.module 'classy'

classy.directive 'paperBtns', ($compile, $state) ->
  restrict: 'A'
  templateUrl: 'partials/paper_buttons'
  scope: exam: '&paperBtns', placeholder:  '@'
  link: ($scope, $elem, attr) ->
    $scope.cut = parseInt (attr.cut || '3'), 10


