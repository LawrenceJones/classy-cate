classy = angular.module 'classy'

classy.factory 'Exams', (CateResource, $q) ->
  class Exams extends CateResource('/api/exams')
    # Gets the exams that the user is timetabled for.
    @getMyExams: ->
      deferred = $q.defer()
      @makeReq('/api/myexams').success (data) ->
        deferred.resolve data
      deferred.promise

    # Pick latest title as default
    title: ->
      @titles[0]

    # Concatenated ID and title
    fulltitle: ->
      "#{@id}: #{@title()}"
        

classy.controller 'ExamsCtrl', ($scope, Exams) ->
  Exams.get().then (exams) ->
    $scope.exams = exams
  Exams.getMyExams().then (data) ->
    $scope.myexams = data.exams

