# Create modules
auth = angular.module 'auth', []
grepdoc = angular.module 'grepdoc', [
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
grepdoc.config [
  '$httpProvider', '$stateProvider', '$urlRouterProvider',
  ($httpProvider,   $stateProvider,   $urlRouterProvider) ->

    # Include http authorization middleware
    $httpProvider.interceptors.push 'authInterceptor'

    # Default route to dashboard
    $urlRouterProvider.otherwise '/profile'

    # Login page for college credentials.
    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login.html'
    }

    # Abstract parent to force loading user first
    $stateProvider.state 'app', {
      abstract: true
      url: '?year'
      reloadOnSearch: false
      resolve:
        user: (AppState) -> AppState.loaded()
    }

    $stateProvider.state 'app.profile', {
      url: '/profile'
      controller: 'ProfileCtrl'
      templateUrl: '/partials/profile.html'
    }

    $stateProvider.state 'app.courses', {
      url: '/courses'
      controller: 'CoursesCtrl'
      templateUrl: '/partials/courses.html'
    }

    $stateProvider.state 'app.courses.view', {
      url: '/:cid'
      controller: 'CoursesViewCtrl'
      templateUrl: '/partials/courses_view.html'
    }

    $stateProvider.state 'app.timetable', {
      url: '/timetable?period'
      controller: ->
      templateUrl: '/partials/timetable.html'
    }

    $stateProvider.state 'app.grades', {
      url: '/grades'
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades.html'
    }

    $stateProvider.state 'app.discussions', {
      url: '/discussions'
      controller: ->
      templateUrl: '/partials/discussions.html'
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
      templateUrl: '/partials/audit.html'
    }

]


# Service to provide useful datas true at this moment of time
grepdoc.service 'Current', (Convert) ->
  academicYear: ->
    if (current = new Date).getMonth() < 8
      return current.getFullYear() - 1
    current.getFullYear()

  period: ->
    3 # TODO: calculate this

  term: ->
    Convert.periodToTerm @period()

# 
grepdoc.service 'AppState', (Auth, Current, Users, $location, $q) ->
  currentYear:    Current.academicYear()
  currentPeriod:  Current.period()
  currentTerm:    Current.term()
  availableYears: [ 2013, 2012 ]
  user: null

  updateYear: (year) ->
    if year in @availableYears then @currentYear = year

  # Returns a promise which resolves with a Users instance encapsulating
  # a user profile. Profile also added to AppState.user
  loaded: ->
    def = $q.defer()
    def.resolve @user if @user?

    (Auth.whoami true)
      .then (login) =>
        (Users.get login: 'thb12').$promise
          .then (response) =>
            @user = (user = response.data)
            def.resolve user
          .catch (err) ->
            def.reject err
      .catch (err) ->
        def.reject err

    def.promise


grepdoc.run ($q, $rootScope, $state, $stateParams, $location, AppState, $http) ->

  # Keep track of state in $rootScope
  $rootScope.$on '$stateChangeSuccess', ($event, state, $stateParams) ->
    $rootScope.currentState = state.name
    $rootScope.courseState  = /app\.courses/.test state.name

    AppState.updateYear (parseInt year) if (year = $stateParams.year)?
      
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

