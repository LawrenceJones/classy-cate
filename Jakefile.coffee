#!/usr/bin/env coffee
# vi: set foldmethod=marker
fs        = require 'fs'
path      = require 'path'
sSplitter = require 'stream-splitter'
$q        = require 'q'
coffee    = require 'coffee-script'
spawn     = (require 'child_process').spawn
exec      = (require 'child_process').exec

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
      process.stdout.write "  #{token}\n"
    sstream.on 'done', -> def.resolve()
    def.promise
  ($q.all [child.stdout, child.stderr].map startLog)
    .then -> do console.log if output# }}}

# Build Helpers ########################################

# Prints message as a white title# {{{
title = (msg) ->
  console.log "\n> #{msg}".white

# Standard logged output
log = (msg) ->
  console.log msg.split(/\r\n/).map((l) -> "  #{l}").join ''

# Print green success message, partner to initial log
succeed = (msg) ->
  console.log "+ #{msg}\n".green

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

desc 'By default, start the dev server'
task 'default', ['start-dev']

desc 'Setup git hooks by symlinking .git/hooks dir'
task 'setup-hooks', [], async: true, ->
  title 'Symlinking git hooks'# {{{
  log 'Removing old ./.git/hooks folder'
  exec 'rm -rf ./.git/hooks', (err) ->
    if err? then fail 'Failed to remove old git folder'
    exec 'ln -s ../hooks ./.git/hooks', (err) ->
      if err? then fail 'Failed to symlink ./.git/hooks to ./hooks'
      succeed 'Successfully symlinked ./.git/hooks -> ./hooks'
      do complete# }}}

desc 'Start dev node server'
task 'start-dev', [], async: true, ->
  title 'Starting nodemon dev server'# {{{
  server = spawn 'nodemon', ['app/app.coffee', '-w', 'app']
  logChild server# }}}

desc 'Inits and updates all git submodules'
task 'init-subs', [], async: true, ->
  title 'Initialising git submodules'# {{{
  exec 'git pull --recurse-submodules', (err) ->
    if err? then fail 'Failed to pull submodules'
    exec 'git submodule init', (err) ->
      if err? then fail 'Failed to init submodules'
      exec 'git submodule update', (err) ->
        if err? then fail 'Failed to update submodules'
        exec 'git submodule foreach git checkout classy', (err) ->
          if err? then fail 'Failed to checkout branch classy'
          succeed 'Successfully init/update git submodules'# }}}

# Classy Tasks #########################################

desc 'Runs a parser class given the supplied parameters'
task 'run-parser', [], async: true, (pfile, params...) ->
  title "Attempting to run parser [#{pfile}]"# {{{
  if !pfile? or not fs.existsSync pfile
    fail 'Please supply valid parser script path as argument'
  Proxy = new (require './app/cate/cate_proxy')(require pfile)

  log 'Loading Imperial credentials from ~/.imp'
  [user, pass] = fs.readFileSync(process.env.HOME+'/.imp', 'utf8').split /\n/
  creds = -> user: user, pass: pass

  # Generate query from args key:val
  query = new Object()
  for param in params
    [key, val] = param.split ':'
    query[key] = val

  # Make request with proxy
  req = Proxy.makeRequest query, creds
  req.then (data) ->
    console.log '\n'+(JSON.stringify data, undefined, 2)+'\n'
    succeed 'Successfully parsed page'
  req.catch (err) ->
    fail err.msg# }}}

# Asset Tasks ##########################################

namespace 'assets', ->

  task 'compile', ['assets:js:compile', 'assets:css:compile'], async: true
  task 'clean', [], async: true, ->
    title 'Attempting to remove compiled assets'# {{{
    rm = spawn 'rm', ['-f', './public/js/app.js', './public/css/app.css']
    handleExit\
    ( rm
    , 'Successfully removed js/css compiled assets'
    , 'Failed to remove js/css compiled assets with code CODE' )# }}}

  namespace 'js', ->

    desc 'Compile all web js into static /public/js/app.js file'
    task 'compile', ['./public/js/app.js'], ->

    # Globs coffee-script from ./web
    coffeeFiles =
      ['./web/modules.coffee'].concat (src for src in lsRecursive './web'\# {{{
        when /\.coffee$/.test(src) and\
             not /\/modules\.coffee$/.test src)# }}}

    desc 'Concatenated client-side code, compiled from ./web'
    file './public/js/app.js', coffeeFiles, async: true, ->
      title 'Compiling web coffee-script to /public/js/app.js'# {{{
      log 'Reading/Compiling files'
      coffeeSource = coffeeFiles.map (f) ->
        fs.readFileSync f, 'utf8'
      jsSource = coffee.compile coffeeSource.join('\n')
      log 'Writing to /public/js/app.js'
      fs.writeFile './public/js/app.js', jsSource, 'utf8', (err) ->
        if err? then fail 'Failed to write to /public/js/app.js'
        succeed 'Successfully written js to /public/js/app.js'
        do complete# }}}

  namespace 'css', ->

    desc 'Compile all scss into static /public/css/app.css file'
    task 'compile', ['./public/css/app.css'], ->

    # Glob scss files in ./stylesheets
    scssFiles = (scss for scss in lsRecursive './stylesheets'\
    when /\.scss$/.test scss)

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

desc 'Install bower components'
task 'install-bower', [], async: true, ->
  title 'Attempting to install bower components'# {{{
  bower = spawn 'bower', ['install'], cwd: __dirname
  logChild bower
  handleExit\
  ( bower
  , 'Successfully installed bower components'
  , 'bower exited with error code CODE' )# }}}

# Versioning ###########################################

proc = versionedPath = livePath = null # declare

namespace 'version', ->

  PROCFILE = './proc.json'

  writeProcfile = ->
    fs.writeFileSync PROCFILE, (JSON.stringify proc, undefined, 2), 'utf8'

  desc 'Loads procfile with deployment status'
  task 'load-proc', [], async: true, ->
    title 'Attempting to read in deploy procfile'# {{{

    try proc = JSON.parse (fs.readFileSync PROCFILE)
    catch err
      fail "Could not parse contents of #{PROCFILE}"

    console.log()
    for own p,val of proc
      log "  #{p}:\t#{val}"
    console.log()

    # Eg. SL/.versions/siteName@version-908123908
    versionedPath = path.join\
    ( proc.siteLocation
    , '.versions'
    , "#{proc.siteName}@#{proc.version}-#{new Date().getTime()}" )

    # Eg. SL/live
    livePath = path.join\
    ( proc.siteLocation
    , 'live' )

    succeed "Successfully read #{PROCFILE}"
    do complete# }}}

  desc 'Bump the version number'
  task 'bump', ['version:load-proc'], (level) ->
    title 'Bumping deploy version\n'# {{{
    i = ['release', 'feature', 'fix'].indexOf level
    if i is -1
      fail "Invalid bump (#{level}), must be release|feature|fix"
    version = proc.version.split('.').map((v) -> parseInt v, 10)
    ++version[i]
    log "Bumping [#{level}] version number..."
    log "  #{proc.version} -> #{(proc.version = version.join '.')}\n"
    do writeProcfile
    succeed 'Successfully wrote new version'# }}}

  desc 'Sets the version number'
  task 'set', ['version:load-proc'], (value) ->
    title "Setting version to #{value}"# {{{
    if not /^[0-9]+\.[0-9]+\.[0-9]+$/.test value
      fail "The version [#{value}] is not a value version number X.X.X"
    proc.version = value
    do writeProcfile
    succeed "Successfully set version number to #{value}"# }}}
    

# Daemon Tasks #########################################

namespace 'daemon', ->

  desc 'Starts the live site daemon'
  task 'start', ['version:load-proc', 'daemon:stop'], async: true, ->
    title 'Attempting to start site daemon'# {{{
    process.chdir livePath
    forever = spawn 'forever', [
      'start'
      '-o', (path.join livePath, 'stdout.log')
      '-e', (path.join livePath, 'stderr.log')
      '-c', 'coffee'
      '--append'
      '--sourceDir', livePath
      '--uid', proc.siteName
      '--minUptime', 24*60*60*1000
      '--spinSleepTime', 60*60*1000
      proc.startScript
    ], cwd: livePath
    logChild forever
    handleExit\
    ( forever
    , 'Successfully launched site daemon!'
    , 'Failed to launch site daemon')# }}}

  desc 'Stops the live site daemon'
  task 'stop', ['version:load-proc'], async: true, ->
    title 'Attempting to stop site daemon'# {{{
    forever = spawn 'forever', ['stop', proc.siteName]
    logChild forever
    forever.on 'exit', ->
      succeed 'Successfully shutdown Site Daemon'
      do complete# }}}


# Deploy Tasks #########################################

desc 'Kickstarts site into production'
task 'deploy', ['install-bower', 'assets:compile', 'deploy:symlink-live'], async: true, ->
  jake.Task['daemon:start'].invoke()

namespace 'deploy', ->

  desc 'Create versioned site directory'
  task 'create-versioned-dir', ['version:load-proc'], async: true, ->
    title 'Attempting to create versioned directory'# {{{
    fs.mkdir (path.join versionedPath, '..'), (err) ->
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
      if fs.existsSync livePath
        fail 'Failed to remove old live path symlink'
      log 'Creating new symlink...'
      fs.symlink versionedPath, livePath, (err) ->
        if err? then fail 'Failed to create new symlink'
        succeed 'Successfully symlinked livepath'
        do complete# }}}
    



