grepdoc = angular.module 'grepdoc'

grepdoc.factory 'Courses', (Resource, AppState, Format, Convert) ->
  class Courses extends Resource({
    actions:
      get: '/api/courses/:year/:cid'
      all: '/api/courses/:year'
    defaultParams:
      year: AppState.currentYear
    relations:
      notes: 'Notes'
      exercises: 'Exercises'
      grades: 'Grades'
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

grepdoc.factory 'Notes', (Resource) ->
  class Notes extends Resource({
    relations:
      time: Date
  })

grepdoc.factory 'Exercises', (Resource) ->
  class Exercises extends Resource({
    relations:
      start: Date
      end: Date
      givens: 'Givens'
  })

grepdoc.factory 'Givens', (Resource) ->
  class Givens extends Resource({
    relations:
      time: Date
  })

grepdoc.controller 'CoursesViewCtrl', ($scope, $stateParams, $state, $q, Courses, Grades) ->

  $q.all [(Courses.get $stateParams).$promise, (Grades.all $stateParams).$promise]
    .then ([course, grades]) ->

      course = course.data
      grades = (grades.data.filter (c) -> c.cid is course.cid)[0]
      course.grades = grades?.clean()?.exercises ? []
      $scope.course = course


    .catch (err) ->
      # For now, transition to courses index if 404: TODO
      $state.go 'app.courses' if err.status is 404


