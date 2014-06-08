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
  template: """
    <div class='panel panel-default'>
      <div class='panel-heading' ui-sref='app.course({mid: course.mid})'>
        <h3 class='panel-title'><a>{{ course.mid + ': ' + course.name }}</a></h3>
      </div>
      <table class='table table-striped panel-body course-grades'>
        <tbody>
          <tr ng-repeat='grade in course.exercises'>
            <td class='number'>{{ grade.number }}</td>
            <td class='icon'><i mime-type-icon='grade.type'></i></td>
            <td class='title'>{{ grade.title }}</td>
            <td class='grade'><grade-badge grade='grade.grade'></td>
          </tr>
        </tbody>
      </table>
    </div>
  """
  scope:
    course: '='

