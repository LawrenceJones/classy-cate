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

    # Routing home
    $stateProvider.state 'dashboard', {
      url: '/'
      abstract: true
      templateUrl: '/partials/dashboard'
    }

    # Routing for login
    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login'
    }

]

classy.run ['$state', '$rootScope', ($state, $rootScope) ->
  $state.transitionTo 'dashboard'
]
  

