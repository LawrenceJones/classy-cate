#!/usr/bin/env coffee
fs        = require 'fs'
path      = require 'path'
spawn     = (require 'child_process').spawn
sSplitter = require 'stream-splitter'
$q        = require 'q'
coffee    = require 'coffee-script'

# Log Styles ###########################################
 
(styles = {# {{{
  # Styles
  bold: [1, 22],        italic: [3, 23]
  underline: [4, 24],   inverse: [7, 27]

  # Grayscale
  white: ['01;38;5;271', 0],    grey: ['01;38;5;251', 0]
  black: ['01;38;5;232', 0]

  # Colors
  blue: ['00;38;5;14', 0],      purple: ['00;38;5;98', 0]
  green: ['01;38;5;118', 0],    orange: ['00;38;5;208', 0]
  red: ['01;38;5;196', 0],      pink: ['01;38;5;198', 0]

})

# Configures for colors and styles
stylize = (str, style) ->
  [p,s] = styles[style]
  `'\033'`+"[#{p}m#{str}"+`'\033'`+"[#{s}m"

# Hack String to hook into our styles
(Object.keys styles).map (style) ->
  String::__defineGetter__(style, -> stylize @, style)

# Log a child processes stdout/err streams
logChild = (child) ->
  output = false
  startLog = (stream) ->
    sstream = stream.pipe sSplitter '\n'
    sstream.encoding = 'utf8'
    def = $q.defer()
    sstream.on 'token', (token) ->
      if !output
        console.log '\n'
        output = true
      process.stdout.write "   #{token}\n"
    sstream.on 'done', -> def.resolve()
    def.promise
  ($q.all [child.stdout, child.stderr].map startLog)
    .then -> do console.log if output# }}}

# Build Helpers ########################################

# Prints message as a white title# {{{
title = (msg) ->
  console.log "\n > #{msg}".white

# Standard logged output
log = (msg) ->
  console.log " > #{msg}"

# Print green success message, partner to initial log
succeed = (msg) ->
  console.log " + #{msg}\n".green

# Halts build chain
fail = (msg) ->
  console.error " ! #{msg}\n".red
  throw new Error msg

# Logs child process exit
handleExit = (child, msgSucc, msgFail) ->
  child.on 'exit', (code) ->
    if code is EXIT_SUCCESS = 0
      succeed msgSucc
      do complete
    else fail msgFail.replace /CODE/g, code

# Recursively list files/folders
lsRecursive = (dir) ->
  [files, folders] = fs.readdirSync(dir).reduce ((a,c) ->
    target = "#{dir}/#{c}"
    isDir = fs.statSync(target).isDirectory()
    a[+(isDir)].push target; a), [[],[]]
  files.concat [].concat (folders.map (dir) -> lsRecursive dir)...# }}}

# Dev Tasks ############################################

desc 'Start dev node server'
task 'start-dev', [], async: true, ->
  title 'Starting nodemon dev server'# {{{
  server = spawn 'nodemon', ['app/app.coffee']
  logChild server# }}}

# Asset Tasks ##########################################

namespace 'assets', ->

  task 'compile', ['assets:js:compile', 'assets:css:compile'], async: true

  namespace 'js', ->

    desc 'Compile all web js into static /public/js/app.js file'
    task 'compile', ['./public/js/app.js'], async: true, ->

    # Globs coffee-script from ./web
    coffeeFiles =
      ['./web/modules.coffee'].concat (src for src in lsRecursive './web'\
        when /\.coffee$/.test(src) and\
             not /\/modules\.coffee$/.test src)

    desc 'Concatenated client-side code, compiled from ./web'
    file './public/js/app.js', coffeeFiles, async: true, ->
      title 'Compiling web coffee-script to /public/js/app.js'# {{{
      log 'Reading/Compiling files'
      jsSource = coffeeFiles.reduce (a,c) ->
        a = (a||'') + (coffee.compile (fs.readFileSync c, 'utf8'))
      log 'Writing to /public/js/app.js'
      fs.writeFile './public/js/app.js', jsSource, 'utf8', (err) ->
        if err? then fail 'Failed to write to /public/js/app.js'
        succeed 'Successfully written js to /public/js/app.js'
        do complete# }}}

  namespace 'css', ->

    desc 'Compile all scss into static /public/css/app.css file'
    task 'compile', ['./public/css/app.css'], async: true, ->

    # Glob scss files in ./stylesheets
    scssFiles = (scss for scss in lsRecursive './stylesheets' when /\.scss$/.test scss)

    desc 'Concatenated css generated from compiled scss files in ./stylesheets'
    file './public/css/app.css', scssFiles, async: true, ->
      title 'Compiling web scss to /public/css/app.css'# {{{
      compileChild = spawn 'coffee', [
        './app/midware/styles.coffee'
        'stylesheets'
        './public/css/app.css'
      ]
      logChild compileChild
      handleExit\
      ( compileChild
      , 'Successfully compiled scss to /public/css/app.css'
      , 'Compilation of scss failed with code CODE' )# }}}

# Package management ###################################

desc 'Install required npm modules'
task 'install-npm-depends', [], async: true, ->
  title 'Attepting to install dependencies via npm'# {{{
  npm = spawn 'npm', ['install']
  logChild npm
  handleExit\
  ( npm
  , 'Successfully installed npm dependencies'
  , 'npm exited with error code CODE' )# }}}

desc 'Install bower components'
task 'install-bower', [], async: true, ->
  title 'Attempting to install bower components'# {{{
  bower = spawn 'bower', ['install']
  logChild bower
  handleExit\
  ( bower
  , 'Successfully installed bower components'
  , 'bower exited with error code CODE' )# }}}

# Deploy Tasks #########################################

task 'deploy', ['deploy:symlink-live'], async: true, ->
namespace 'deploy', ->

  desc 'Loads properties file'
  props = versionedPath = livePath = null # declare
  task 'load-props', ['install-npm-depends'], async: true, ->
    title 'Attempting to read in build properties'# {{{
    props = JSON.parse (fs.readFileSync 'props.json')
    for own prop,val of props
      console.log "    #{p}:\t#{val}".grey

    # Eg. SL/.versions/siteName@version-908123908
    versionedPath = path.join\
    ( props.siteLocation
    , '.versions'
    , "#{props.siteName}@#{props.version}-#{new Date().getTime()}" )

    # Eg. SL/siteName
    livePath = path.join\
    ( props.siteLocation
    , props.siteName )

    succeed 'Successfully read properties'
    do complete# }}}

  desc 'Create versioned site directory'
  task 'create-versioned-dir', ['deploy:load-props'], async: true, ->
    title 'Attempting to create versioned directory'# {{{
    fs.mkdir versionedPath, (err) ->
      if err? then fail 'Failed to create versioned directory'
      succeed 'Successfully created versioned directory'
      do complete# }}}

  desc 'Move files to location'
  task 'move-files', ['deploy:create-versioned-dir'], async: true, ->
    title 'Attempting to move files'# {{{
    exec "rsync -a . #{versionedPath}", (err, stdout, stderr) ->
      if err? then fail 'Failed to move files'
      succeed 'Successfully moved files'
      do complete# }}}

  desc 'Symlink new version'
  task 'symlink-live', ['deploy:move-files'], async: true, ->
    title 'Attempting to make symbolic links'# {{{
    log 'Removing old symlink...'
    fs.unlink livePath, (err) ->
      if err? then fail 'Failed to remove old live path symlink'
      log 'Creating new symlink...'
      fs.symlink versionedPath, livePath, (err) ->
        if err? then fail 'Failed to create new symlink'
        succeed 'Successfully symlinked livepath'
        do complete# }}}

  desc 'Kickstarts site into production'
  task 'deploy', ['deploy:symlink-live'], async: true, ->
    title 'Attempting to push to launch site into production'# {{{
    do complete # TODO - Complete# }}}


