classy = angular.module 'classy'

classy.factory 'Dashboard', (CateResource, $rootScope, $q) ->
  return class Dashboard extends CateResource('/api/dashboard')
    @get: ->
      promise = super
      promise.then (res) ->
        $rootScope.available_years = res.available_years
        $rootScope.current_year ?= res.year
      return promise

classy.controller 'DashboardCtrl', ($scope, Dashboard) ->

  $scope.input =
    period: 0, klass: null

  # Adjusts for the holiday periods
  $scope.adjustPeriod = (p) ->
    if (p % 2 == 0) or p is 7
      p - 1
    else p

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

  find = (value, collection) ->
    for o in collection
      if o.value == value then return o

  Dashboard.get().then (dash) ->
    $scope.dashboard = dash
    $scope.input.klass =
      find dash.default_class, $scope.klassOptions
    $scope.input.period = periodLabelLookup dash.default_period

