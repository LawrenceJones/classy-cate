# Create modules
auth = angular.module 'auth', []
classy = angular.module 'classy', [
  'ui.router'
  'ui.bootstrap.modal'
  'ui.bootstrap.accordion'
  'ui.bootstrap.tooltip'
  'infinite-scroll'
  'auth'
  'resource'
]

# Save the initial window state
window.initialState = window.location.hash

Date::format = ->
  [d, m] = [@getDate(), @getMonth() + 1].map (n) ->
    ('000' + n).slice -2
  "#{d}/#{m}/#{@getFullYear()}"

Date::printTime = ->
  @toTimeString().match(/^(\d+):(\d+)/)[0]

# Configure the routes for the module
classy.config [
  '$httpProvider', '$stateProvider', '$urlRouterProvider',
  ($httpProvider,   $stateProvider,   $urlRouterProvider) ->

    # Include http authorization middleware
    $httpProvider.interceptors.push 'authInterceptor'

    # Default route to dashboard
    $urlRouterProvider.otherwise '/dashboard'

    # Abstract parent to force dash loading first
    $stateProvider.state 'app', {
      abstract: true
    }

    # Splash entry page with user info.
    $stateProvider.state 'app.dashboard', {
      url: '/dashboard'
      controller: (->)
      templateUrl: '/partials/dashboard'
    }

    # Login page for college credentials.
    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login'
    }

    $stateProvider.state 'app.profile', {
      url: '/profile'
      controller: 'ProfileCtrl'
      templateUrl: '/partials/profile'
    }

    $stateProvider.state 'app.courses', {
      url: '/courses?year'
      controller: 'CoursesCtrl'
      templateUrl: '/partials/courses'
      canTimeTravel: true
    }

    $stateProvider.state 'app.courses.view', {
      url: '/:cid'
      controller: 'CoursesViewCtrl'
      templateUrl: '/partials/course_view'
      canTimeTravel: true
    }

    $stateProvider.state 'app.timetable', {
      url: '/timetable?year&period'
      controller: ->
      templateUrl: '/partials/timetable'
      canTimeTravel: true
    }

    $stateProvider.state 'app.grades', {
      url: '/grades?year'
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades'
      canTimeTravel: true
    }

    $stateProvider.state 'app.discussions', {
      url: '/discussions'
      controller: ->
      templateUrl: '/partials/discussions'
    }


    # Security audit information
    $stateProvider.state 'audit', {
      url: '/audit'
      resolve:
        hits: ($http, $q) ->
          def = $q.defer()
          $http.get('/audit').success (hits) ->
            def.resolve hits
          def.promise
      controller: 'AuditCtrl'
      templateUrl: '/partials/audit'
    }

]

classy.run ($q, $rootScope) ->

  # Keep track of state in $rootScope
  $rootScope.$on '$stateChangeSuccess', ($event, state) ->
    $rootScope.currentState = state.name
    $rootScope.courseState = /app\.courses/.test state.name
    $rootScope.canTimeTravel = state.canTimeTravel? and state.canTimeTravel

  $rootScope.AppState =
    currentYear:
      if (current = new Date).getMonth() < 8 then current.getFullYear() - 1
      else current.getFullYear()


  $rootScope.timeTravelYears = [
    {
      year: 2013
      class: 'c2'
    }
    {
      year: 2012
      class: 'c1'
    }
  ]

  $rootScope.registeredCourses = [
    {
      name: 'Software Engineering - Algorithms'
      cid: '202'
    }
    {
      name: 'Operating Systems'
      cid: '211'
    }
    {
      name: 'Networks and Communications'
      cid: '212'
    }
    {
      name: 'Introduction to Artificial Intelligence'
      cid: '231'
    }
    {
      name: 'Computational Techniques'
      cid: '233'
    }
    {
      name: 'Laboratory 2'
      cid: '261'
    }
    {
      name: '2nd Year Group Projects'
      cid: '271'
    }
    {
      name: 'Team Skills Development'
      cid: '272'
    }
    {
      name: 'Introduction to Prolog'
      cid: '276'
    }
  ]

