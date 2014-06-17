# NPM modules
express    = require 'express'
fs         = require 'fs'
path       = require 'path'
jwt        = require 'express-jwt'
nodetime   = require 'nodetime'
morgan     = require 'morgan'
compress   = require 'compression'
bodyParser = require 'body-parser'
memwatch   = require 'memwatch'

# Local modules
config   = require './etc/config'
ngget    = require './midware/angular'
partials = require './midware/partials'
seedApi  = require './midware/seed_api'

# Load extra js utilities
utils = require './etc/utilities'

# Determine NODE_ENV
NODE_ENV = process.NODE_ENV ? 'development'

# Load server prov.json
proc = JSON.parse(fs.readFileSync './proc.json', 'utf8')

# Init app
module.exports = class GrepDoc

  constructor: (@app = express(), @proc = proc) ->
    do @configure

  # Loads basic server configuration
  configure: (ENV = NODE_ENV) ->

    # Init app settings
    @app.set 'title', 'Catie'
    @app.set 'view engine', 'jade'
    @app.set 'views', config.paths.views_dir
    @app.set 'json spaces', (if ENV == 'production' then 0 else 2)

    # Configure middleware
    @app.use morgan('dev')                                     # logger
    @app.use bodyParser.json()                                 # json
    @app.use bodyParser.urlencoded()                           # params

  # Connects to mongodb client
  connectDb: ->
    (require './etc/db').connect(config)

  # Routes in sequential order
  route: ->
    do @connectDb
    [
      # TODO
    ]
      .map (routePath) =>
        (require routePath).configure(@app)

  # This is the setup of the jsonwebtoken access. The jwt middleware
  # will decode any authorization headers on incoming requests into
  # a function, located on req.user.
  #
  # To enable easy tracking of credential use, the function will only
  # return the credentials if it is passed 'USER_CREDENTIALS' as a
  # parameter. This enables easy prevention of credential abuse.
  usejwt: ->
    @app.use '/api', jwt
      secret: config.express.SECRET
      lock: 'USER_CREDENTIALS'

  # Hot compile transpiled assets, for dev only
  hotCompile: ->
    cssget = require './midware/styles'
    @app.get '/css/app.css', cssget config.paths.styles_dir     # sass
    @app.get '/js/app.js', ngget                                # app.js
      angularPath: config.paths.web_dir
    @app.use partials                                           # jade
      views:  config.paths.views_dir
      prefix: '/partials'

  # Supply json seed if present
  seedApi: ->
    app.use '/api', seedApi
      seedDir: config.paths.seed_dir
      prefix: '/api'

  # Serves static web assets from a public directory
  serveStatic: ->
    @app.use express.static config.paths.public_dir

  # Loads authentication over /api routes
  secureAPI: ->
    (require './auth').configure @app

  # Starts the app on the given PORT
  run: (PORT = (proc.port ? process.env.PORT), cb) ->
    server = @app.listen PORT, (err) ->
      if err then cb? err, 'Failed to start server'
      cb? null, "Listening at localhost:#{PORT}"
    server


if !module.parent
  grepDoc = new GrepDoc
  grepDoc.usejwt()
  grepDoc.secureAPI()
  grepDoc.hotCompile() if NODE_ENV == 'development'
  grepDoc.route()
  grepDoc.serveStatic()
  grepDoc.run undefined, (err, msg) ->
    if err then throw new Error msg
    else console.log msg
