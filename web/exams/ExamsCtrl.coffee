classy = angular.module 'classy'

classy.factory 'Exams', (CateResource, $q) ->
  myExams = []
  deferred = $q.defer()
  class Exams extends CateResource('/api/exams')

    # Keeps track of whether the data is loaded.
    @loaded: deferred.promise

    # Gets the exams that the user is timetabled for.
    @getMyExams: ->
      @makeReq('/api/myexams').success (data) =>
        deferred.resolve data
        myExams = (e.id for e in data.exams)
      deferred.promise

    # Evalutates whether the given exam id is one the user
    # is timetables to take.
    @isMyExam: (id) ->
      for _id in myExams
        return true if _id == id
      false

    # Pick latest title as default
    title: ->
      @titles[0]

    # Concatenated ID and title
    fulltitle: ->
      "#{@id}: #{@title()}"
        

classy.controller 'ExamsCtrl', ($scope, exams, myexams) ->
  $scope.exams = exams
  $scope.myexams = myexams

