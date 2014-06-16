classy = angular.module 'classy'

classy.directive 'courseCell', ->

  restrict: 'A'
  replace: true
  scope: course: '=courseCell'
  template: """
          <tr>
            <td class='panel panel-default'>
              <div class='wrap-cell'>
                {{course.name}}
              </div>
            </td>
          </tr>
  """
  link: ($scope, $elem, attr) ->
    length = $scope.course.rows.length
    newHeight = (parseInt $elem.css 'height') * length
    $elem.css('height', "#{newHeight}px")


classy.directive 'daysBar', ->
  restrict: 'A'
  replace: true
  template: """
          <thead>
            <tr>
              <th ng-repeat='day in days track by $index'>
                <div class='wrap-cell'>
                  {{day}}
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
                {{box.ex.name}}
              </div>
            </td>
  """
  link: ($scope, $elem, attr) ->
    ex = ($scope.$eval attr.box).ex
    $elem.addClass "panel panel-default #{getExerciseClass ex.type}" if ex?
