# Create modules
auth = angular.module 'auth', []
classy = angular.module 'classy', [
  'ui.router'
  'auth'
]

# Configure the routes for the module
classy.config [
  '$httpProvider', '$stateProvider', '$urlRouterProvider',
  ($httpProvider,   $stateProvider,  $urlRouterProvider) ->

    # Include http authorization middleware
    $httpProvider.interceptors.push 'authInterceptor'

    $stateProvider.state 'dashboard', {
      url: '/'
      resolve:
        dash: (Dashboard) -> Dashboard.get()
      controller: 'DashboardCtrl'
      templateUrl: '/partials/dashboard'
    }

    $stateProvider.state 'grades', {
      url: '/grades'
      resolve:
        grades: (Grades) -> Grades.get()
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades'
    }

    $urlRouterProvider.when '/exercises', ($rootScope, $state) ->
      $state.transitionTo 'exercises', {
        year: $rootScope.current_year
        klass: $rootScope.default_klass
        period: $rootScope.default_period
      }

    $stateProvider.state 'exercises', {
      url: '/exercises?year&period&klass'
      templateUrl: '/partials/exercises'
    }

    $stateProvider.state 'exams', {
      url: '/exams'
      resolve:
        exams: (Exams) -> Exams.get()
        myexams: (Exams) -> Exams.getMyExams().then (data) -> data.exams
      controller: 'ExamsCtrl'
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
  

