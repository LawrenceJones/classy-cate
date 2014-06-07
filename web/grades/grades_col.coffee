classy = angular.module 'classy'

classy.directive 'courseGrades', ->
  restrict: 'E'
  replace: true
  template: """
    <div class='panel panel-default'>
      <div class='panel-heading'>
        <h3 class='panel-title'>{{ course.mid + ': ' + course.name }}</h3>
      </div>
      <table class='table table-hover panel-body'>
        <tbody>
          <tr ng-repeat='grade in course.exercises'>
            <td>{{ grade.number }}</td>
            <td><i mime-type-icon='grade.type'></i></td>
            <td>{{ grade.title }}</td>
            <td>{{ grade.grade }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  """
  scope:
    course: '='

