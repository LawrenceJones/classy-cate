classy = angular.module 'classy'

classy.factory 'Dashboard', (Resource, $rootScope, $q) ->
  class Dashboard extends Resource(baseurl: '/api/dashboard')
    # Adjusts for the holiday periods
    @adjustPeriod: (p) ->
      if (p % 2 == 0) or p is 7
        p - 1
      else p

    # Calculates cates current year
    @currentYear: ->
      y = (d = new Date()).getFullYear()
      --y if d.getMonth() < 8
      y


    # Sets rootScope properties when refreshed
    @query: (query = {}) ->

      # Set default year if not already set.
      query.year ?= @currentYear()
      promise = super query

      # Hook AppState into this parser
      promise.then (res) =>
        AppState = $rootScope.AppState
        years = res.availableYears
        if years.indexOf res.year is -1
          years.push res.year
        AppState.currentUser = res.login
        AppState.availableYears = years.map (y) -> parseInt y, 10
        AppState.currentYear = parseInt res.year, 10
        AppState.currentPeriod ?=
          AppState.defaultPeriod ?= @adjustPeriod(res.defaultPeriod)
        AppState.currentClass ?=
          AppState.defaultClass ?= res.defaultClass
        $rootScope.authDefer.resolve AppState
      return promise

classy.controller 'DashboardCtrl', ($scope, $state, $rootScope, Dashboard, dash) ->

  $scope.input =
    period: 0, klass: null

  $scope.adjustPeriod = Dashboard.adjustPeriod

  $scope.periodOptions = [
    { label: 'Autumn', value: 1 }
    { label: 'Spring', value: 3 }
    { label: 'Summer', value: 5 }
    { label: 'June-July', value: 6 }
  ]

  periodLabelLookup = (val) ->
    _p = $scope.adjustPeriod val
    for p in $scope.periodOptions
      if p.value is _p then return p

  $scope.klassOptions = [
    { value: 'c1', label: 'COMP 1' }
    { value: 'c1', label: 'COMP 1' }
    { value: 'c2', label: 'COMP 2' }
    { value: 'c3', label: 'COMP 3' }
    { value: 'c4', label: 'COMP 4' }
    { value: 'j1', label: 'JMC 1' }
    { value: 'j2', label: 'JMC 2' }
    { value: 'j3', label: 'JMC 3' }
    { value: 'j4', label: 'JMC 4' }
    { value: 'i2', label: 'ISE 2' }
    { value: 'i3', label: 'ISE 3' }
    { value: 'i4', label: 'ISE 4' }
    { value: 'v5', label: 'Computing' }
    { value: 's5', label: 'Computing Spec' }
    { value: 'a5', label: 'Advanced' }
    { value: 'r5', label: 'Research' }
    { value: 'y5', label: 'Industrial' }
    { value: 'b5', label: 'Bioinformatic' }
    { value: 'occ', label: 'Occasional' }
    { value: 'r6', label: 'PhD' }
    { value: 'ext', label: 'External' }
  ]

  $scope.gotoExercises = ->
    $state.transitionTo 'exercises',
      class:  $rootScope.AppState.currentClass
      period: $rootScope.AppState.currentPeriod
      year:   $rootScope.AppState.currentYear

  find = (value, collection) ->
    for o in collection
      if o.value == value then return o

  $scope.dashboard = dash
  $scope.input.klass =
    find dash.defaultClass, $scope.klassOptions
  $scope.$watch 'input.klass', (_new) ->
    if _new?.value?
      $rootScope.AppState.currentClass = _new.value
  $scope.input.period = periodLabelLookup dash.defaultPeriod
  $scope.$watch 'input.period', (_new) ->
    if _new?.value?
      $rootScope.AppState.currentPeriod = _new.value

