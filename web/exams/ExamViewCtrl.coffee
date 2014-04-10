classy = angular.module 'classy'

classy.controller 'ExamViewCtrl', ($scope, exam, me) ->
  $scope.negScore = (u) ->
    -(u.upvotes - u.downvotes)
  $scope.exam = exam
  $scope.me = me

