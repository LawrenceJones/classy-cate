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

# Load extra js utilities
utils = require './etc/utilities'

# Listen for leaks
memwatch.on 'leak', (stats) ->
  console.error stats

# Init app
app = (configure = (app, config) ->

  ENV = app.settings.env

  # Init app settings
  app.set 'title', 'Catie'
  app.set 'view engine', 'jade'
  app.set 'views', config.paths.views_dir
  app.set 'json spaces', (if ENV == 'production' then 0 else 2)

  # Configure middleware
  app.use morgan('dev')                                     # logger
  app.use compress()                                        # gzip
  app.use bodyParser.json()                                 # json
  app.use bodyParser.urlencoded()                           # params

  # If on heroku, force https
  if process.env.ON_HEROKU
    app.use (req, res, next) ->
      reqType = req.headers['x-forwarded-proto']
      if reqType == 'https' then next()
      else
        res.redirect "https://#{req.headers.host}#{req.url}"

  # Configure nodetime if env has config
  if process.env.NODETIME_APP_NAME?
    nodetime.profile config.nodetime

  # Decode the user credentials
  app.use '/api', (req, res, next) ->
    if !req.headers.authorization? && req.query.token?
      req.headers.authorization = "Bearer #{req.query.token}"
    next()

  # This is the setup of the jsonwebtoken access. The jwt middleware
  # will decode any authorization headers on incoming requests into
  # a function, located on req.user.
  # To enable easy tracking of credential use, the function will only
  # return the credentials if it is passed 'USER_CREDENTIALS' as a
  # parameter. This enables easy prevention of credential abuse.
  app.use '/api', jwt
    secret: config.express.SECRET
    lock: 'USER_CREDENTIALS'
  app.use '/api', (req, res, next) ->
    if req.user?
      # Access login to mark a user into the config hash. This is only
      # to enable no of user tracking, only a login is recorded.
      config.users[req.user('USER_CREDENTIALS').user] = true
      next()
    else res.send 401, 'Token expired!'

  # Live compilation, shouldnt be used in production
  if ENV == 'development'
    app.get '/env', (req, res) -> res.send 'dev'
    cssget = require './midware/styles'
    app.get '/css/app.css', cssget config.paths.styles_dir     # sass
    app.get '/js/app.js', ngget                                # app.js
      angularPath: config.paths.web_dir
    
  # Asset serving
  app.use express.static config.paths.public_dir            # static
  app.use partials                                          # jade
    views:  config.paths.views_dir
    prefix: '/partials'

  return app

)(express(), config)

# Start database
(require './etc/db')(config)

# Load routes in given order
[
  './auth/auth_router'
  './dashboard/dashboard_router'
  './grades/grades_router'
  './notes/notes_router'
  './givens/givens_router'
  './exercises/exercises_router'
  './exams/exam_router'
  './uploads/upload_router'
  './modules/cate_module_router'
]
  .map (routePath) ->
    (require routePath)(app)

# Load app
app.listen (PORT = process.env.PORT || 4567), ->
  console.log "Started server running in #{app.settings.env}"
  console.log "Listening at https://localhost:#{PORT}"

