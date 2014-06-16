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

classy.factory 'DateUtils', ->
  Date::format = ->
    [d, m] = [@getDate(), @getMonth() + 1].map (n) ->
      ('000' + n).slice -2
    "#{d}/#{m}/#{@getFullYear()}"

  Date::printTime = ->
    @toTimeString().match(/^(\d+):(\d+)/)[0]
  
  # Return an array of js dates in the range from the
  # object date, to the given date
  Date::getDatesTo = (end) ->
    range = []
    current = new Date(@) #Starting date
    while current <= end
      range.push current
      current = new Date(current) #Starting date
      current.setDate (current.getDate() + 1)
    range


  # Returns a js date representing the midnight time.
  Date::midnight = ->
    mn = new Date(@)
    mn.setHours 0, 0, 0, 0
    mn

  return Date.prototype

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

    $stateProvider.state 'app.courses', {
      url: '/courses'
      controller: ->
      templateUrl: '/partials/courses'
    }

    $stateProvider.state 'app.courses.view', {
      url: '/:cid'
      controller: 'CourseCtrl'
      templateUrl: '/partials/course_view'
    }

    $stateProvider.state 'app.timetable', {
      url: '/timetable'
      controller: 'TimetableCtrl'
      templateUrl: '/partials/timetable'
    }

    $stateProvider.state 'app.grades', {
      url: '/grades'
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades'
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

classy.run ($q, $rootScope, DateUtils) ->
  
  # Keep track of state in $rootScope
  $rootScope.$on '$stateChangeSuccess', ($event, state) ->
    $rootScope.currentState = state.name
    $rootScope.courseState = /app\.courses/.test state.name

  $rootScope.registeredCourses = [
    {
      name: 'Software Engineering - Algorithms'
      cid: '202'
    }
    {
      name: 'Operating Systems'
      cid: '211'
    }
  ]

