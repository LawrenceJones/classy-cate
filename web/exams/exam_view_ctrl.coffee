classy = angular.module 'classy'

classy.controller 'ExamViewCtrl', ($scope, $modal, Exam, modules, exam) ->

  $scope.exam = exam
  $scope.modules = modules
  $scope.negScore = (u) ->
    -(u.upvotes - u.downvotes)

  $scope.notRelated = ->
    return $scope.exam.rCache if $scope.exam.rCache
    modules = modules.sort (a,b) -> a.id - b.id
    relatedIds = $scope.exam.related.map (r) -> r.id
    $scope.exam.rCache = modules.filter (m) -> relatedIds.indexOf(m.id) == -1
      
  $scope.linkModule = (module) ->
    $scope.exam.relateModule module

  $scope.removeModule = (module) ->
    $scope.exam.removeModule module

      
classy.filter 'hasSpecOrGiven', ->
  (exs) ->
    exs.filter (ex) -> ex.spec? or ex.givens?
