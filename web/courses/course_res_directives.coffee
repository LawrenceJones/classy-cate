classy = angular.module 'classy'

classy.directive 'courseNote', ($window) ->
  restrict: 'A'
  templateUrl: '/partials/directives/course_note'
  scope: note: '='
  replace: true

classy.directive 'courseExercise', ->
  restrict: 'A'
  templateUrl: '/partials/directives/course_exercise'
  scope: exercise: '='
  replace: true

  link: ($scope, $tbody, attr) ->
    $tbody.find("td.title a").on 'click', ->
      $tbody.closest("table").find("tbody").not($tbody).find(".ex-given").addClass("hide")
      $tbody.find(".ex-given").toggleClass("hide")


classy.directive 'discussionsBadge', (Format) ->
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
    num = $scope.discussions?.length
    $db
      .addClass "progress-bar-#{getCol $scope.discussions?.length}"
      .attr("title", "#{num} #{Format.pluraliseIf 'discussion', num} on this resource")
      .tooltip()
