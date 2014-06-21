grepdoc = angular.module 'grepdoc'

grepdoc.directive 'courseCell', ->

  restrict: 'A'
  replace: true
  scope: course: '=courseCell'
  template: """
          <tr>
            <td class='panel panel-default'>
              <div class='wrap-cell'>
               <a course-link='course'> {{course.name}} </a>
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

grepdoc.directive 'periodBar', ->
  restrict: 'A'
  replace: true
  templateUrl: '/partials/directives/timetable_period_bar.html'

  link: ($scope, $elem, attr) ->
    # Makes the dayBar fixed
    # $elem.parent().floatThead (scrollingTop: 50)

grepdoc.directive 'exerciseBox', ->

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
                <span ng-if='box.ex'>{{box.ex.num}}: {{box.ex.title}}</span>
              </div>
            </td>
  """
  link: ($scope, $elem, attr) ->
    box = $scope.box

    highlightsDays = ->
      [start, end] = box.options.position
      $('#days-bar').find('th').map (i, e) ->
        $(e).addClass 'highlighted-day' if start <= i <= end

    removeHighlightsDays = ->
      $('.highlighted-day').map (i, e) ->
        $(e).removeClass 'highlighted-day'

    if box.ex?
      $elem
        .addClass "panel panel-default exercise #{getExerciseClass box.ex}"
        .hover highlightsDays, removeHighlightsDays
    else
      $elem.addClass "today" if box.options.isToday
    



    # grepdoc.controller 'MyCtrl', ($state) ->
    #     $state.go 'app.timetable', (year: 2013, period: 3, class: "c2")
    #
    #
    ###
