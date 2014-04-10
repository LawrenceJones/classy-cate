# Create modules
auth = angular.module 'auth', []
classy = angular.module 'classy', [
  'ui.router'
  'ui.bootstrap.modal'
  'ui.bootstrap.accordion'
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

    # Splash entry page with user info.
    $stateProvider.state 'dashboard', {
      url: '/dashboard'
      resolve:
        dash: (Dashboard) -> Dashboard.get()
      controller: 'DashboardCtrl'
      templateUrl: '/partials/dashboard'
    }

    # Personal student record.
    $stateProvider.state 'grades', {
      url: '/grades'
      resolve:
        grades: (Grades) -> Grades.get()
      controller: 'GradesCtrl'
      templateUrl: '/partials/grades'
    }

    # Redirect any blank attempts to access exercises.
    $urlRouterProvider.when '/exercises', ($state, $stateParams, Exercises) ->
      params = Exercises.initParams $stateParams
      $state.transitionTo 'exercises', params

    # Exercises state, defined by the year klass period params.
    $stateProvider.state 'exercises', {
      url: '/exercises?year&period&klass'
      templateUrl: '/partials/exercises'
      resolve:
        exercises: ($stateParams, Exercises, Dashboard) ->
          Dashboard.get().then ->
            Exercises.get $stateParams
      controller: 'ExercisesCtrl'
    }

    # Index page for past papers.
    $stateProvider.state 'exams', {
      url: '/exams'
      resolve:
        exams: (Exam) -> Exam.get()
        myexams: (Exam) -> Exam.getMyExams()
        modules: (Module) -> Module.getAll()
      controller: 'ExamsCtrl'
      templateUrl: '/partials/exams'
    }

    # Per exam view of that subject.
    $stateProvider.state 'exams.view', {
      url: '/:id'
      resolve:
        exam: (Exam, $stateParams) ->
          Exam.getOneById $stateParams.id
        me: (Auth) -> Auth.whoami()
      controller: 'ExamViewCtrl'
      templateUrl: '/partials/exam_view'
    }

    # Login page for college credentials.
    $stateProvider.state 'login', {
      url: '/login'
      templateUrl: '/partials/login'
    }

]

classy.run ($state, $rootScope, Dashboard) ->
  Dashboard.get()
  

