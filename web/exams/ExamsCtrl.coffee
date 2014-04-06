classy = angular.module 'classy'

classy.factory 'MyExams', (CateResource) ->
  class MyExams extends CateResource('/api/myexams')

classy.factory 'Exams', (CateResource) ->
  class Exams extends CateResource('/api/exams')

classy.controller 'ExamsCtrl', ($scope, MyExams, Exams) ->
  $scope.exams = []
  Exams.get().then (data) ->
    console.log data
  MyExams.get().then (data) ->
    $scope.myexams = data.exams

