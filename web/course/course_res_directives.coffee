classy = angular.module 'classy'

classy.directive 'courseNote', ($window) ->
  restrict: 'A'
  link: ($scope, $tr, attr) ->
    $tr.on 'click', ->
      $window.open $scope.$eval(attr.courseNote), '_blank'

classy.directive 'courseExercise', ->
  restrict: 'A'
  link: ($scope, $tr, attr) ->
    $tr.on 'click', ->
      console.log "Will expand to show resources for #{$scope.$eval attr.courseExercise}"

  # TODO

