classy = angular.module 'classy'

classy.factory 'Courses', (Resource, $rootScope, Format, Convert) ->
  class Courses extends Resource({
    actions:
      get: '/api/courses/:year/:cid'
      all: '/api/courses/:year'
    defaultParams:
      year: $rootScope.AppState.currentYear
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
      "This course runs in the #{Format.asEnglishList terms} #{Format.pluraliseIf 'term', terms.length}"

classy.factory 'Notes', (Resource) ->
  class Notes extends Resource({
    relations:
      time: Date
  })

classy.factory 'Exercises', (Resource) ->
  class Exercises extends Resource({
    relations:
      start: Date
      end: Date
  })

classy.controller 'CoursesViewCtrl', ($scope, $stateParams, $state, Courses) ->
  ($scope.course = Courses.get $stateParams).$promise
  .then (response) ->
    
    console.log (course = response.data)
    # console.log course.validFrom.getFullYear()


  .catch (err) ->
    # For now, transition to courses index if 404: TODO
    $state.go 'app.courses' if err.status is 404

