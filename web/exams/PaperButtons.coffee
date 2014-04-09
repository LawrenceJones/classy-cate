classy = angular.module 'classy'

classy.directive 'paperBtns', ($compile, $state) ->
  restrict: 'A'
  controller: 'PaperCtrl'
  templateUrl: 'partials/paper_buttons'
  scope: true
  link: ($scope, $elem, attr) ->
    $scope.exam = $scope.$eval attr.paperBtns
    $scope.placeholder = attr.placeholder
    $scope.cut = parseInt (attr.cut || '3'), 10


