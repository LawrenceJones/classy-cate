classy = angular.module 'classy'

getPerc = (grade) ->
  for test in [
    [ /^A\*$/,  'A*',  100, 'progress-bar-success' ]
    [ /^A\+$/,  'A+',  90,  'progress-bar-success' ]
    [ /^A$/,    'A',   80,  'progress-bar-success' ]
    [ /^B$/,    'B',   70,  'progress-bar-success' ]
    [ /^C$/,    'C',   60,  'progress-bar-warning' ]
    [ /^D$/,    'D',   50,  'progress-bar-warning' ]
    [ /^E$/,    'E',   40,  'progress-bar-danger'  ]
    [ /^F$/,    'F',   25,  'progress-bar-danger'  ]
    [ /n\/a/, 'NA' ]
    [ /ZERO/, 'ZERO' ]
    [ /\=DD\=/, 'Deferred Decision' ]
    [ /GNFP/, 'Grades not for publish' ]
  ]
    [rex, str, score, klass] = test
    if rex.test grade
      return [str, score, klass]
  

classy.directive 'gradeBar', ->
  restrict: 'CE'
  template: """
    <div class="progress">
      <div class="progress-bar" role="progressbar"
           aria-valuemin="0" aria-valuemax="100">
      </div>
    </div>
  """
  link: ($scope, $elem, attr) ->
    grade = ($scope.$eval attr.grade).trim()
    if grade == ''
      return $elem.remove()
    if (res = getPerc grade)?
      [label, score, klass] = res
      $bar = $elem.find '.progress-bar'
      if score?
        $bar.css {width: "#{score}%"}
        $bar.addClass klass
        $elem = $elem.find '.progress-bar'
    $elem.html(label || grade)


