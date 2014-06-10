classy = angular.module 'classy'


classy.directive 'gradeBadge', ->

  getColourClass = (grade) ->
    if /^(A[\*+]?)|B$/.test grade then return 'success'
    if /^[C-D]$/.test grade then return 'warning'
    if /^[E-F]$/.test grade then return 'danger'
    return 'info'

  restrict: 'E'
  replace: true
  template: """
    <div class='progress'>
      <div class='progress-bar' role='progressbar' aria-valuenow='1' 
       aria-valuemin='0' aria-valuemax='1' style='width: 100%'></div>
    </div>
  """

  link: ($scope, $elem, attr) ->
    grade = $scope.$eval(attr.grade)
    $elem.find(".progress-bar")
      .addClass "progress-bar-#{getColourClass grade}"
      .text grade


classy.directive 'courseGrades', ->
  restrict: 'E'
  replace: true
  templateUrl: '/partials/directives/course_grades'
  scope:
    course: '='

