classy = angular.module 'classy'

classy.directive 'courseSelector', ->
  restrict: 'A'
  replace: true
  templateUrl: '/partials/directives/course_selector'
  scope: courses: '='
  link: ($scope, $i, attr) ->

classy.directive 'courseOption', ->
  restrict: 'A'
  replace: true
  template: """
    <li class='course-option' id='co-{{ course.mid }}' 
        ui-sref='app.courses.view({mid:course.mid})' ui-sref-active='active')>
      <a>{{ course.mid + ': ' + course.name }}</a>
    </li>
  """
  scope: course: '='
  link: ($scope, $i, attr) ->
