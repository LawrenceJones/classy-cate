sharedConfig = require './karma.SHARED.conf'

module.exports = (config) ->

  conf = do sharedConfig

  conf.files = conf.files.concat [
    # extra testing code
    'public/lib/angular-mocks/angular-mocks.js',
    # All unit tests to be required
    './test/client/unit/**/*.spec.coffee'
  ]

  config.set conf
