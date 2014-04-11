classy = angular.module 'classy'

classy.controller 'PaperCtrl', ($scope, Exam) ->

  $scope.input =
    mineonly: false
  $scope.input.mineonly = true
  $scope.$watchCollection 'input', (_input) ->
    $scope.input.rex = new RegExp _input.search, 'i'
    $scope.loading = false

  $scope.noToDisplay = 10
  $scope.loading = false
  $scope.filterExams = (exams, max) ->
    filter = (exam) ->
      match = $scope.input.rex.test "#{exam.titles[0]}#{exam.name}"
      mineonly = $scope.input.mineonly
      match && (if mineonly then Exam.isMine exam.id else true)
    filtered = exams.reduce ((a,c) ->
      a.push c if a.length < max && filter c; a), []
    $scope.loading = filtered.length < max
    filtered

  $scope.loadMore = ->
    $scope.loading = true
    $scope.noToDisplay += 8
    $scope.$apply() if !$scope.$$phase





