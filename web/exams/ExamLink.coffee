classy = angular.module 'classy'

classy.directive 'examLink', ($compile, $state) ->
  restrict: 'A'
  link: ($scope, $elem, attr) ->
    exam = $scope.$eval attr.examLink
    $elem.text exam.title(true)
    $elem.click ->
      $state.transitionTo 'exams.view', {id: exam.id}

