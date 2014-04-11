classy = angular.module 'classy'

classy.controller 'ExamViewCtrl', ($scope, $modal, Exam, exam, me) ->
  $scope.negScore = (u) ->
    -(u.upvotes - u.downvotes)
  $scope.exam = exam
  $scope.me = me
  $scope.notRelated = (modules) ->
    return $scope.exam.rCache if $scope.exam.rCache
    modules = modules.sort (a,b) -> a.id - b.id
    relatedIds = $scope.exam.related.map (r) -> r.id
    $scope.exam.rCache = modules.filter (m) -> relatedIds.indexOf(m.id) == -1
      
  $scope.linkModule = (module) ->
    related = $scope.exam.relateModule module
    related.then (exam) ->
      $scope.exam = exam
    related.catch (err) ->
      console.error err

  $scope.removeModule = (module) ->
    removed = $scope.exam.removeModule module
    removed.then (exam) ->
      $scope.exam = exam

      

