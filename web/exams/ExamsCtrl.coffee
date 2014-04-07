classy = angular.module 'classy'

classy.factory 'Exams', (CateResource, $q) ->
  class Exams extends CateResource('/api/exams')
    @getMyExams: ->
      deferred = $q.defer()
      @makeReq '/api/myexams'
        .success (data) ->
          deferred.resolve data
      deferred.promise

classy.controller 'ExamsCtrl', ($scope, Exams) ->
  $scope.exams = []
  Exams.get().then (data) ->
    console.log data
  Exams.getMyExams().then (data) ->
    $scope.myexams = data.exams

