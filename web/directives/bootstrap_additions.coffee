classy = angular.module 'classy'

# Support hover dropdown toggle
classy.directive 'dropdownHover', ->
  restrict: 'AC'
  link: ($scope, $a, attr) ->
    $dd = $a.parent()
    $a.hover\
    ( (-> $dd.addClass('open'))
    , (-> $dd.removeClass('open')) )


