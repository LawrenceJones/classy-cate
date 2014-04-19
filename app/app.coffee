# NPM modules
express    = require 'express'
https      = require 'https'
fs         = require 'fs'
path       = require 'path'
cheerio    = require 'cheerio'
jwt        = require 'express-jwt'

# Local modules
config   = require './etc/config'
ngget    = require './midware/angular'
partials = require './midware/partials'

# Load extra js utilities
utils = require './etc/utilities'

# Init app
app = (configure = (app, config) ->

  # Init app settings
  app.set 'title', 'Doc Exams'
  app.set 'view engine', 'jade'
  app.set 'views', config.paths.views_dir

  # Configure middleware
  app.use express.logger('dev')                             # logger
  app.use express.json()                                    # json
  app.use express.urlencoded()                              # params

  # If on heroku, force https
  if process.env.ON_HEROKU then app.use (req, res, next) ->
    reqType = req.headers['x-forwarded-proto']
    if reqType == 'https' then next()
    else
      res.redirect "https://#{req.headers.host}#{req.url}"

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
    if req.user? then next()
    else res.send 401, 'Token expired!'

  # Live compilation, shouldnt be used in production
  if app.settings.env == 'development'
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
app.listen (PORT = process.env.PORT || 80), ->
  console.log "Listening at https://localhost:#{PORT}"

