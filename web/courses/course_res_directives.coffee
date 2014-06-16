classy = angular.module 'classy'

classy.directive 'courseNote', ($window) ->
  restrict: 'A'
  link: ($scope, $tr, attr) ->
    $tr.find("td.title a").on 'click', ->
      $window.open $scope.$eval(attr.courseNote), '_blank'


classy.directive 'courseExercise', ->
  restrict: 'A'
  link: ($scope, $tbody, attr) ->

    $tbody.find("td.title a").on 'click', ->
      $tbody.closest("table").find("tbody").not($tbody).find(".ex-given").addClass("hide")
      $tbody.find(".ex-given").toggleClass("hide")


classy.directive 'discussionsBadge', ->
  getCol = (num) ->
    return 'success' if num > 10
    return 'info' if 5 < num <= 10
    return 'warning' if 1 < num <= 5
    return ''

  restrict: 'E'
  template: "<span class='badge disc-badge' data-toggle='tooltip' data-placement='left'
              ui-sref='app.discussions'>{{ discussions.length }}</span>"
  scope: discussions: '='
  replace: true
  link: ($scope, $db, attr) ->
    $db
      .addClass "progress-bar-#{getCol $scope.discussions?.length}"
      .attr("title", "#{$scope.discussions?.length} discussions")
      .tooltip()
