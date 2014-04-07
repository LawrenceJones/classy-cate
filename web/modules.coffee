# Create modules
auth = angular.module 'auth', []
classy = angular.module 'classy', [
  'ui.router'
  'auth'
]

# Configure the routes for the module
classy.config [
  '$httpProvider', '$stateProvider',
  ($httpProvider,   $stateProvider) ->

    # Include http authorization middleware
    $httpProvider.interceptors.push 'authInterceptor'

    $stateProvider.state 'dashboard', {
      url: '/'
      templateUrl: '/partials/dashboard'
    }

    $stateProvider.state 'grades', {
      url: '/grades'
      templateUrl: '/partials/grades'
    }

    $stateProvider.state 'exercises', {
      url: '/exercises?year&period&klass'
      templateUrl: '/partials/exercises'
    }

    $stateProvider.state 'exams', {
      url: '/exams'
      templateUrl: '/partials/exams'
    }

    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login'
    }

]

classy.run ['$state', '$rootScope', 'Dashboard'
  ($state, $rootScope, Dashboard) ->
    Dashboard.get()
    $state.transitionTo 'dashboard'
]
  

