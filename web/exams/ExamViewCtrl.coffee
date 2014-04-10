classy = angular.module 'classy'

classy.controller 'ExamViewCtrl', ($scope, $modal, Exam, exam, me) ->
  $scope.negScore = (u) ->
    -(u.upvotes - u.downvotes)
  $scope.exam = exam
  $scope.me = me
  $scope.notRelated = (modules) ->
    modules = modules.sort (a,b) -> a.id - b.id
    relatedIds = exam.related.map (r) -> r.id
    modules.filter (m) -> relatedIds.indexOf(m.id) == -1
      
  $scope.linkModule = (module) ->
    related = exam.relateModule module
    related.then (data) ->
      console.log data
      $scope.exam.related = data.related
    related.catch (err) ->
      console.error err
      

