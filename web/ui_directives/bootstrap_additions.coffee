grepdoc = angular.module 'grepdoc'

# Support hover dropdown toggle
grepdoc.directive 'dropdownHover', ->
  restrict: 'AC'
  link: ($scope, $a, attr) ->
    $dd = $a.parent()
    $a.hover\
    ( (-> $dd.addClass('open'))
    , (-> $dd.removeClass('open')) )


