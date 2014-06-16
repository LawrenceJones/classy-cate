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
    length = $scope.course.rows.length
    borderSpacing = parseInt $elem.parent().css 'border-spacing'
    padding = parseInt $elem.find('td').css 'padding'
    border = parseInt $elem.find('td').css 'border'
    wrap = borderSpacing + 2 * (padding + border)
    newHeight = (parseInt $elem.css 'height') * length - wrap
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

  getExerciseClass = (type) ->
    ({
      CW:  'coursework'
      TUT: 'tutorial'
    })[type?.toUpperCase()] || 'other-exercise'

  restrict: 'A'
  replace: true
  scope: box: '='
  template: """
            <td colspan='{{box.options.colspan}}' ng-class='{today: box.options.isToday}'>
              <div class='wrap-cell'>
                <i ng-if='box.ex' mime-type-icon='box.ex.type'></i>
                {{box.ex.name}}
              </div>
            </td>
  """
  link: ($scope, $elem, attr) ->
    ex = ($scope.$eval attr.box).ex
    $elem.addClass "panel panel-default #{getExerciseClass ex.type}" if ex?
