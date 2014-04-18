# Create modules
auth = angular.module 'auth', []
resource = angular.module 'resource', []
classy = angular.module 'classy', [
  'ui.router'
  'ui.bootstrap.modal'
  'ui.bootstrap.accordion'
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
      url: '/grades'
      resolve:
        grades: (Grades, $rootScope, dash) ->
          Grades.query
            year: $rootScope.AppState.currentYear
            user: $rootScope.AppState.currentUser
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades'
    }

    # Redirect any blank attempts to access exercises.
    $urlRouterProvider.when '/exercises', ($state, $stateParams, $rootScope) ->
      AppState = $rootScope.AppState
      for own k,_ of AppState
        AppState[k] = $stateParams[k] if $stateParams[k]?
      $state.transitionTo 'app.exercises', {
        year: AppState.currentYear
        period: AppState.currentPeriod
        class: AppState.currentClass
      }

    # Exercises state, defined by the year klass period params.
    $stateProvider.state 'app.exercises', {
      url: '/exercises?year&period&class'
      templateUrl: '/partials/exercises'
      resolve:
        exercises: ($stateParams, Exercises) ->
          Exercises.query $stateParams
      controller: 'ExercisesCtrl'
    }

    # Index page for past papers.
    $stateProvider.state 'app.exams', {
      url: '/exams'
      resolve:
        exams: (Exam) -> Exam.get()
        myexams: (Exam) -> Exam.getMyExams()
        modules: (Module) -> Module.getAll()
      controller: 'ExamsCtrl'
      templateUrl: '/partials/exams'
    }

    # Per exam view of that subject.
    $stateProvider.state 'app.exams.view', {
      url: '/:id'
      resolve:
        exam: (Exam, $stateParams) ->
          Exam.getOneById $stateParams.id
        me: (Auth) -> Auth.whoami()
      controller: 'ExamViewCtrl'
      templateUrl: '/partials/examView'
    }

    # Login page for college credentials.
    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login'
    }

]

classy.service 'init', (Dashboard) ->
  @loaded = Dashboard.query().then (data) =>
    angular.extend this, data

classy.run ($state, $location, $rootScope, Dashboard) ->
  Dashboard.query()
  $rootScope.$on '$stateChangeSuccess', ($event, state) ->
    $rootScope.currentState = state.name

  # Globally available application state
  $rootScope.AppState =
    currentYear:    Dashboard.currentYear()
    currentClass:   null
    currentPeriod:  3 # just a guess
    currentUser:    null


