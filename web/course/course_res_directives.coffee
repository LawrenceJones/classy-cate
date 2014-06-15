classy = angular.module 'classy'

classy.directive 'courseNote', ($window) ->
  restrict: 'A'
  link: ($scope, $tr, attr) ->
    $tr.on 'click', ->
      $window.open $scope.$eval(attr.courseNote), '_blank'

classy.directive 'courseExercise', ->
  restrict: 'A'
  link: ($scope, $tbody, attr) ->

    $tbody.find(".ex-title").on 'click', ->
      $tbody.closest("table").find("tbody").not($tbody).find(".ex-given").addClass("hide")
      $tbody.find(".ex-given").toggleClass("hide")

