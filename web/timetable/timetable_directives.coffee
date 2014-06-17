classy = angular.module 'classy'

classy.directive 'courseCell', ->

  restrict: 'A'
  replace: true
  scope: course: '=courseCell'
  template: """
          <tr>
            <td class='panel panel-default'>
              <div class='wrap-cell'>
               <a course-link='course'> {{course.name}} 
              </div>
            </td>
          </tr>
  """
  link: ($scope, $elem, attr) ->
    # Setting the cell's height of the course name equal to the
    # total height of the exercises row for the particular course
    border = parseInt $elem.find('td').css 'border'
    length = $scope.course.rows.length
    newHeight = (parseInt $elem.css 'height') * length - border
    $elem = $elem.find('.wrap-cell')
    $elem.css('height', "#{newHeight}px")
    $elem.css('line-height', "#{newHeight}px")


classy.directive 'daysBar', ->
  restrict: 'A'
  replace: true
  template: """
          <thead>
            <tr>
              <th colspan='{{values["size"]}}' ng-repeat='(month, values) in period.months'>
                <div class='wrap-cell'>
                  {{values['name']}}
                </div>
              </th>
            </tr>

            <tr>
              <th ng-repeat='day in period.days track by $index' ng-class='{today: day.isToday, weekend: day.isWeekend}'>
                <div class='wrap-cell'>
                  {{day.number}}
                </div>
              </th>
            </tr>
          </thead>
  """

  link: ($scope, $elem, attr) ->
    # Makes the dayBar fixed
    # $elem.parent().floatThead (scrollingTop: 50)

classy.directive 'exerciseBox', ->

  getExerciseClass = (ex) ->
    if ex.group and ex.assessed
      return 'group-assessed'
    else if ex.assessed
      return 'assessed'
    else if ex.submission
      return 'submission'
    else
      return 'default-exercise'

  restrict: 'A'
  replace: true
  scope: box: '='
  template: """
            <td colspan='{{box.options.colspan}}'>
              <div class='wrap-cell'>
                <i ng-if='box.ex' mime-type-icon='box.ex.type'></i>
                {{box.ex.name}}
              </div>
            </td>
  """
  link: ($scope, $elem, attr) ->
    box = ($scope.$eval attr.box)
    if box.ex?
      $elem.addClass "panel panel-default exercise #{getExerciseClass box.ex}"
    else
      $elem.addClass "today" if box.options.isToday
