grepdoc = angular.module 'grepdoc'

grepdoc.controller 'ExerciseModalCtrl', ($scope, $modalInstance, $stateParams,
                                        TimetableGivens, Current, ex, cid) ->

  $scope.ex = ex
  $scope.cid = cid
  
  $scope.givens = TimetableGivens.get {
      year: $stateParams.year, cid: cid, num: ex.num
    }

  $scope.getInfo = ->
    type = if ex.group then 'A group' else 'An individual'
    assessed = if ex.assessed then 'assessed' else 'unassessed'
    submission = if ex.submission then ', requiring submission' else ''
    msg = "#{type}, #{assessed} exercise#{submission}"

  $scope.getSubmissionInfo = ->
    if ex.submission
      if Current.isToday(ex.end)
        'Hurry up! Submission is due today!'
      else if Date.now() > ex.end
        'The deadline for submission is already passed!'
      else
        daysLeft = ex.end.getDate() - new Date(Date.now()).getDate()
        plural = if daysLeft > 1 then 's' else ''
        "You still have #{daysLeft} day#{plural} left before the deadline"
    else if ex.spec
      'No submission is required, but why don\'t you give it a try?'



grepdoc.factory 'TimetableGivens', (Resource, AppState) ->
  class Givens extends Resource({
    actions:
      get: '/api/courses/:year/:cid/exercises/:num/givens'
    defaultParams:
      year: AppState.currentYear
  })
