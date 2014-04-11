classy = angular.module 'classy'

classy.directive 'examLink', ($compile, $state) ->
  restrict: 'A'
  link: ($scope, $elem, attr) ->
    exam = $scope.$eval attr.examLink
    $elem.text exam.title(true)
    $elem.click ->
      $state.transitionTo 'exams.view', {id: exam.id}

classy.directive 'moduleUnlinkBtn', (Exam) ->
  restrict: 'AC'
  controller: (Exam, $scope) ->
    $scope.remove = (module) ->
      removed = $scope.exam.removeModule module
      removed.then (exam) ->
        angular.extend $scope.exam, exam
  template: """
    <a ng-click="remove(module)"><i class="delete fa fa-trash-o"></i></a>
  """
  scope: module: '=', exam: '='
  link: ($scope, $elem, attr) ->
    $elem.click (e) ->
      e.stopPropagation()
