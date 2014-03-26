classy = angular.module 'classy'

classy.factory 'Dashboard', (CateResource) ->
  class Dashboard extends CateResource('/api/dashboard')

classy.controller 'DashboardCtrl', ($scope, Dashboard) ->
  Dashboard.get().then (dash) ->
    $scope.dashboard = dash

