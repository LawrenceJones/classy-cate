classy = angular.module 'classy'

classy.factory 'Courses', (Resource, AppState, Format, Convert) ->
  class Courses extends Resource({
    actions:
      get: '/api/courses/:year/:cid'
      all: '/api/courses/:year'
    defaultParams:
      year: AppState.currentYear
    relations:
      validTo: Date
      validFrom: Date
  })

    formatTerms: ->
      @terms?.join ", "

    formatClasses: ->
      @classes?.join "  "

    describeTerms: ->
      return if not @terms?
      terms = @terms.map (term) -> Convert.termToName term
      "This course runs in the #{Format.asEnglishList terms} 
        #{Format.pluraliseIf 'term', terms.length}"

classy.controller 'CoursesViewCtrl', ($scope, $stateParams, course, grades, Notes, Exercises) ->

  filterGrades = (grades, cid) ->
    grades = (grades.filter (c) -> c.cid is cid)[0]
    grades?.clean()?.exercises ? []

  $scope.course    = course
  $scope.grades    = filterGrades grades, course.cid
  $scope.notes     = Notes.get $stateParams
  $scope.exercises = Exercises.get $stateParams

