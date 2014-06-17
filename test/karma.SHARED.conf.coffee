module.exports = ->

  basePath: '../'
  frameworks: ['mocha']
  reporters: ['spec', 'growl']

  # preprocess matching files before serving them to the browser
  # available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
  preprocessors:
    '**/*.coffee': ['coffee']
    '**/*.jade': ['ng-jade2js']

  # TODO - Not yet working
  ngJade2JsPreprocessor:
    # Strip this from the file path
    stripPrefix: 'views/'
    # Prepend this to the
    prependPrefix: 'partials/'
    # Allow loading with module('templates')
    moduleName: 'templates'
  
  # list of files / patterns to load in the browser
  files : [

    # 3rd Party Code
    'public/lib/jquery/dist/jquery.js'
    'public/lib/angular/angular.js'
    'public/lib/angular-ui-router/release/angular-ui-router.js'
    'public/lib/ngInfiniteScroll/build/ng-infinite-scroll.min.js'
    'public/lib/ui.bootstrap/src/transition/transition.js'
    'public/lib/ui.bootstrap/src/accordion/accordion.js'
    'public/lib/ui.bootstrap/src/collapse/collapse.js'
    'public/lib/ui.bootstrap/src/modal/modal.js'
    'public/lib/ui.bootstrap/src/bindHtml/bindHtml.js'
    'public/lib/ui.bootstrap/src/position/position.js'
    'public/lib/ui.bootstrap/src/tooltip/tooltip.js'
    'public/lib/bootstrap/dist/js/bootstrap.js'

    # View files
    'views/*.jade'

    # Data seeds
    'test/seeds/*.coffee'

    # Module registration
    'web/modules.coffee'

    # App-specific Code
    'web/**/*.coffee'

    # Extra testing units
    'node_modules/chai/chai.js'
    'test/client/lib/chai-should.coffee'
    'test/client/lib/chai-expect.coffee'

  ]

  exclude: [
    'test/seeds/index.coffee'
  ]

  # start these browsers
  # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
  browsers: ['PhantomJS'] # ['Chrome', 'Firefox', 'Safari']

  # automatic watching and execution of files and tests
  autoWatch: true

  # these are default values anyway
  singleRun: false
  colors: true

  # web server port
  port: 9876

