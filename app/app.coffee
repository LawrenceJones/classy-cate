# NPM modules
express    = require 'express'
fs         = require 'fs'
path       = require 'path'
cheerio    = require 'cheerio'
jwt        = require 'express-jwt'

# Local modules
config   = require './config'
ngget    = require './midware/angular'
partials = require './midware/partials'

# Init app
app = (configure = (app, config) ->

  # Init app settings
  app.set 'title', 'classy-cate'
  app.set 'view engine', 'jade'
  app.set 'views', config.paths.views_dir

  # Configure middleware
  app.use express.logger('dev')                             # logger
  app.use express.json()                                    # json
  app.use express.urlencoded()                              # params

  # For testing, configure auth_header on req
  if config.cate.USER && config.cate.PASS
    app.use '/api', (req, res, next) ->
      req.user =
        user: config.cate.USER
        pass: config.cate.PASS
      next()
  else
    # Decode the user credentials
    app.use '/api', jwt
      secret: config.express.SECRET

  # Live compilation, shouldn't be used in production
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

cheerio::elemAt = (sel, i) ->
  (@find sel).eq i

# Start database
(require './db')(config)

# Load routes in given order
[
  './auth'
  './api/routes'
]
  .map (routePath) ->
    (require routePath)(app)

# Load app
server = app.listen (PORT = process.env.PORT || 80), ->
  console.log "Listening at localhost:#{PORT}"

