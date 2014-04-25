# Create modules
auth = angular.module 'auth', []
resource = angular.module 'resource', []
classy = angular.module 'classy', [
  'ui.router'
  'ui.bootstrap.modal'
  'ui.bootstrap.accordion'
  'ui.bootstrap.tooltip'
  'infinite-scroll'
  'resource'
  'auth'
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
      resolve:
        dash: (Dashboard) ->
          Dashboard.query()
    }

    # Splash entry page with user info.
    $stateProvider.state 'app.dashboard', {
      url: '/dashboard'
      controller: 'DashboardCtrl'
      templateUrl: '/partials/dashboard'
    }

    # Personal student record.
    $stateProvider.state 'app.grades', {
      url: '/grades?year&user&class'
      resolve:
        grades: (Grades, $state, $location, $stateParams, dash) ->
          if Grades.initParams $stateParams
            $state.transitionTo 'app.grades', $stateParams
          Grades.query $stateParams
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades'
    }

    # Exercises state, defined by the year klass period params.
    $stateProvider.state 'app.exercises', {
      url: '/exercises?year&period&class&user'
      templateUrl: '/partials/exercises'
      resolve:
        exercises: ($stateParams, $location, $state, dash, Exercises) ->
          if Exercises.initParams $stateParams
            $state.transitionTo 'app.exercises', $stateParams
          Exercises.query $stateParams
      controller: 'ExercisesCtrl'
    }

    # Index page for past papers.
    $stateProvider.state 'app.exams', {
      url: '/exams'
      resolve:
        exams: (Exam) ->
          Exam.query {}
        modules: (Module) ->
          Module.query()
      controller: 'ExamsCtrl'
      templateUrl: '/partials/exams'
    }

    # Per exam view of that subject.
    $stateProvider.state 'app.exams.view', {
      url: '/:id'
      resolve:
        exam: (Exam, $stateParams) ->
          Exam.get $stateParams.id
      controller: 'ExamViewCtrl'
      templateUrl: '/partials/exam_view'
    }

    # Login page for college credentials.
    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login'
    }

    # Security audit information
    $stateProvider.state 'audit', {
      url: '/audit'
      resolve:
        hits: ($http, $q) ->
          $http.get('/audit').success (hits) ->
            def.resolve hits
          (def = $q.defer()).promise
      controller: 'AuditCtrl'
      templateUrl: '/partials/audit'
    }

]

classy.service 'init', (Dashboard) ->
  @loaded = Dashboard.query().then (data) =>
    angular.extend this, data

classy.run ($q, $rootScope, Dashboard, ExamTimetable) ->

  # Keep track of state in $rootScope
  $rootScope.$on '$stateChangeSuccess', ($event, state) ->
    $rootScope.currentState = state.name

  # Keep promise for when dashboard has been resolved
  $rootScope.authed = ($rootScope.authDefer = $q.defer()).promise

  # Query exam timetable now, so it's cached
  ExamTimetable.query()

  # Globally available application state
  $rootScope.AppState =
    currentYear:    Dashboard.currentYear()
    currentClass:   null
    currentPeriod:  3 # just a guess
    currentUser:    null


