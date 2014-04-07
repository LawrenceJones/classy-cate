classy = angular.module 'classy'

classy.factory 'Dashboard', (CateResource, $rootScope, $q) ->
  return class Dashboard extends CateResource('/api/dashboard')
    @get: ->
      promise = super
      promise.then (res) ->
        $rootScope.available_years = res.available_years
      return promise

classy.controller 'DashboardCtrl', ($scope, Dashboard) ->
  $scope.input =
    period: 0, klass: null
  $scope.periodOptions = [
    { label: 'Autumn', value: 1 }
    { label: 'Spring', value: 3 }
    { label: 'Summer', value: 5 }
    { label: 'June-July', value: 6 }
  ]

  # Adjusts for the holiday periods
  $scope.adjustPeriod = (p) ->
    if (p % 2 == 0) or p is 7
      p - 1
    else p

  Dashboard.get().then (dash) ->
    $scope.dashboard = dash
    $scope.input.klass = dash.default_class
    $scope.input.period = dash.default_period

