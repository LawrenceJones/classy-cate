classy = angular.module 'classy'

classy.controller 'ExamsCtrl', ($scope, exams, ExamTimetable, Exam) ->

  $scope.exams = exams
  $scope.input =
    mineonly: true # default for now
    search: ''

  ExamTimetable.query().then (tt) ->
    $scope.examTimetable = tt
    $scope.myexams = tt.exams
    $scope.loadMore 1
    $scope.input.mineonly = true

  searchRex = new RegExp()
  $scope.$watchCollection 'input', ->
    fCache = null
    searchRex = new RegExp $scope.input.search, 'i'
    $scope.loading = false
    $scope.loadMore 1

  $scope.noToDisplay = 10
  $scope.loading = false

  fCache = null

  $scope.filterExams = (exams, max) ->
    return fCache if fCache?
    filter = (exam) ->
      match = searchRex.test "#{exam.titles[0]}#{exam.name}"
      mineonly = $scope.input.mineonly
      match && (if mineonly then Exam.isMine exam.id else true)
    fCache = exams.reduce ((a,c) ->
      a.push c if a.length < max && filter c; a), []
    $scope.loading = fCache.length < max
    fCache

  $scope.loadMore = (inc = 8) ->
    fCache = null
    $scope.loading = true
    $scope.noToDisplay += inc
    $scope.$apply() if !$scope.$$phase

