classy = angular.module 'classy'

classy.directive 'examLink', ($compile, $state) ->
  restrict: 'A'
  link: ($scope, $elem, attr) ->
    exam = $scope.$eval attr.examLink
    $elem.text exam.title?(true) || "#{exam.id}: #{exam.title}"
    $elem.click ->
      $state.transitionTo 'app.exams.view', id: exam.id

classy.directive 'moduleUnlinkBtn', (Exam) ->
  restrict: 'AC'
  template: """
    <a><i class="delete fa fa-trash-o"></i></a>
  """
