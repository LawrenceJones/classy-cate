classy = angular.module 'classy'

classy.factory 'Exam', (CateResource, Module, $q) ->
  myExams = []
  class Exam extends CateResource('/api/exams')

    # Wrap the related modules in a module class
    constructor: (data, @related = []) ->
      angular.extend @, data
      @related = (new Module m for m in @related)

    # Gets the exams that the user is timetabled for.
    @getMyExams: ->
      deferred = $q.defer()
      @makeReq('/api/myexams').success (data) =>
        deferred.resolve data.exams
        myExams = (e.id for e in data.exams)
      deferred.promise


    # Evalutates whether the given exam id is one the user
    # is timetables to take.
    @isMyExam: (id) ->
      for _id in myExams
        return true if _id == id
      false

    # Pick latest title as default
    title: (full) ->
      t = @titles[0]
      if full then "#{@id}: #{t}" else t

    # Lists other titles
    otherTitles: ->
      @titles[1..].join ', '


classy.controller 'ExamsCtrl', ($scope, exams, myexams) ->
  $scope.exams = exams
  $scope.myexams = myexams

