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
  String::__defineGetter__(style, -> stylize @, style)# }}}

# Build Helpers ########################################

# Takes a prefix and a writeable stream _w. Returns a stream that when# {{{
# written too, will pipe input to _w, prefixed with pre on every newline.
pipePrefix = (pre, _w) ->
  sstream = sSplitter('\n')
  sstream.encoding = 'utf8'
  sstream.on 'token', (token) ->
    _w.write pre+token+'\n'
  return sstream

# Run the given commands sequentially, returning a promise for
# command resolution.
chain = (cmds..., opt) ->
  run = (cmd, cmds...) ->
    [exe, args, fmsg, check, wd] = cmd
    check ?= (err) -> err == 0
    wd ?= __dirname
    prompt "#{exe} #{args.join ' '}"
    prog = spawn exe, args, cwd: wd || __dirname
    prog.stdout.pipe pOut
    prog.stderr.pipe pErr
    prog.on 'exit', (err) ->
      do newline
      if !check err
        def.reject err, fmsg
      else if cmds.length != 0 then run cmds...
      else
        do def.resolve

  def = $q.defer()
  promise = def.promise

  # Process last argument
  if opt instanceof Array
    if opt.length == 1
      [smsg] = opt
      promise.then ->
        succeed smsg
      promise.catch (err, fmsg) ->
        fail "[#{err}] #{fmsg}"
      opt = null
  cmds.push opt if opt?

  # Run commands
  do newline
  run cmds... if cmds.length > 0
  def.promise

# Recursively list files/folders
lsRecursive = (dir) ->
  [files, folders] = fs.readdirSync(dir).reduce ((a,c) ->
    target = "#{dir}/#{c}"
    isDir = fs.statSync(target).isDirectory()
    a[+(isDir)].push target; a), [[],[]]
  files.concat [].concat (folders.map (dir) -> lsRecursive dir)...# }}}

# Logging Aliases ######################################

# Prints message as a white title# {{{
title = (msg) ->
  console.log "\n> #{msg}".white

# Standard logged output
log = (msg) ->
  console.log msg.split(/\r\n/).map((l) -> "  #{l}").join ''

# Alias for empty console.log
newline = console.log

# Print green success message, partner to initial log
succeed = (msg) ->
  console.log "+ #{msg}\n".green

# Halts build chain
fail = (msg) ->
  console.error "! #{msg}\n".red
  throw new Error msg

# Prints command as if from prompt
prompt = (cmd) ->
  console.log "$ #{cmd}"
pOut = pipePrefix '  ', process.stdout
pErr = pipePrefix '  ', process.stderr# }}}

# Dev Tasks ############################################

desc 'By default, start the dev server'
task 'default', ['start-dev']

desc 'Setup git hooks by symlinking .git/hooks dir'
task 'setup-hooks', [], async: true, ->
  title 'Symlinking git hooks'# {{{
  chain\
  ( [ 'rm', ['-rf', './.git/hooks']
    , 'Failed to remove old git folder'
    , (-> !fs.existsSync './.git/hooks') ]
    [ 'ln', ['-s', '../hooks', './.git/hooks']
    , 'Failed to symlink ./.git/hooks -> ./hooks' ]
    # Success output
    [ 'Successfully symlinked ./.git/hooks -> ./hooks' ]
  ).finally complete# }}}

desc 'Start dev node server'
task 'start-dev', [], async: true, ->
  title 'Starting nodemon dev server'# {{{
  server = spawn\
  ( 'nodemon'
  , ['app/app.coffee', '-w', 'app']
  , stdio: ['ignore', 'pipe', 'pipe'] )
  do newline
  stdout = pipePrefix '  ', process.stdout
  server.stdout.pipe stdout# }}}

desc 'Inits and updates all git submodules'
task 'init-subs', [], async: true, ->
  title 'Initialising git submodules'# {{{
  chain\
  ( [ 'git', ['submodule', 'update', '--init', '--recursive']
    , 'Failed to update and init each submodule' ]
    [ 'git', ['submodule', 'foreach', 'git', 'checkout', 'classy']
    , 'Failed to checkout project branch of submodules' ]
    # Success output
    [ 'Successfully init/update git submodules' ]
  )# }}}

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

  task 'compile', ['assets:js:compile', 'assets:css:compile'], ->
  task 'clean', [], async: true, ->
    title 'Attempting to remove compiled assets'# {{{
    chain\
    ( [ 'rm', ['-f', './public/js/app.js', './public/css/app.css']
      , 'Failed to remove js/css compiled assets'
      , (-> !(fs.existsSync('./public/js/app.js')\
        ||  fs.existsSync('./public/css/css.js'))) ]
      # Success output
      [ 'Successfully compiled js/css assets' ]
    )# }}}

  namespace 'js', ->

    desc 'Compile all web js into static public/js/app.js file'
    task 'compile', ['public/js/app.js'], ->

    # Globs coffee-script from ./web
    coffeeFiles =
      ['./web/modules.coffee'].concat (src for src in lsRecursive './web'\# {{{
        when /\.coffee$/.test(src) and\
             not /\/modules\.coffee$/.test src)# }}}

    desc 'Concatenated client-side code, compiled from ./web'
    file 'public/js/app.js', coffeeFiles, async: true, ->
      title 'Compiling web coffee-script to public/js/app.js'# {{{
      log 'Reading/Compiling files'
      coffeeSource = coffeeFiles.map (f) ->
        fs.readFileSync f, 'utf8'
      jsSource = coffee.compile coffeeSource.join('\n')
      log 'Writing to public/js/app.js'
      fs.writeFile './public/js/app.js', jsSource, 'utf8', (err) ->
        if err? then fail 'Failed to write to /public/js/app.js'
        succeed 'Successfully written js to /public/js/app.js'
        do complete# }}}

  namespace 'css', ->

    desc 'Compile all scss into static public/css/app.css file'
    task 'compile', ['public/css/app.css'], ->

    # Glob scss files in ./stylesheets
    scssFiles = (scss for scss in lsRecursive './stylesheets'\
    when /\.scss$/.test scss)

    desc 'Concatenated css generated from compiled scss files in ./stylesheets'
    file 'public/css/app.css', scssFiles, async: true, ->
      title 'Compiling web scss to public/css/app.css'# {{{
      chain\
      ( [ 'coffee'
        , ['./app/midware/styles.coffee', 'stylesheets', './public/css/app.css']
        , 'Failed to run midware compilation scripts' ]
        [ 'Successfully compiled scss to public/css/app.css' ]
      )# }}}

# Package management ###################################

desc 'Install bower components'
task 'install-bower', [], async: true, ->
  title 'Attempting to install bower components'# {{{
  chain\
  ( [ 'bower', ['install']
    , 'Failed to run bower' ]
    # Success output
    [ 'Successfully installed bower dependencies' ]
  ).finally complete# }}}

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

    do newline
    for own p,val of proc
      log "  #{p}:\t#{val}"
    do newline

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
    version[j] = 0 for j in [i+1..version.length-1]
    log "Bumping [#{level}] version number..."
    log "  #{proc.version} -> #{(proc.version = version.join '.')}\n"
    do writeProcfile
    succeed 'Successfully wrote new version', false# }}}

  desc 'Sets the version number'
  task 'set', ['version:load-proc'], (value) ->
    title "Setting version to #{value}"# {{{
    if not /^[0-9]+\.[0-9]+\.[0-9]+$/.test value
      fail "The version [#{value}] is not a value version number X.X.X"
    proc.version = value
    do writeProcfile
    succeed "Successfully set version number to #{value}", false# }}}
    

# Daemon Tasks #########################################

namespace 'daemon', ->

  desc 'Starts the live site daemon'
  task 'start', async: true, ->
    stop = jake.Task['daemon:stop']# {{{
    stop.addListener 'complete', ->
      title 'Attempting to start site daemon'
      chain\
      ( [ 'forever'
        , [
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
          ]
        , 'Failed to start forever', null, livePath ]
        # Success output
        [ 'Successfully launched site daemon!' ]
      )
    stop.invoke()# }}}

  desc 'Stops the live site daemon'
  task 'stop', ['version:load-proc'], async: true, ->
    title 'Attempting to stop site daemon'# {{{
    chain\
    ( [ 'forever', ['stop', proc.siteName]
      , 'Failed to stop site daemon'
      , (-> true) ]
      # Success output
      [ 'Successfully shutdown Site Daemon' ]
    )# }}}

# Deploy Tasks #########################################

desc 'Kickstarts site into production'
task 'deploy', [
  'assets:compile'
  'version:load-proc'
  'deploy:create-versioned-dir'
  'deploy:move-files'
  'deploy:symlink-live'
  'daemon:stop'
  'daemon:start'
], ->

namespace 'deploy', ->

  desc 'Create versioned site directory'
  task 'create-versioned-dir', ['version:load-proc'], async: true, ->
    title 'Attempting to create versioned directory'# {{{
    chain\
    ( [ 'mkdir', ['-p', path.join versionedPath, '..']
      , 'Failed to make versioned directory' ]
      # Success output
      [ 'Successfully made versioned directory' ]
    )# }}}

  desc 'Move files to location'
  task 'move-files', [
    'version:load-proc'
    'deploy:create-versioned-dir'
  ], async: true, ->
    title 'Attempting to move files'# {{{
    chain\
    ( [ 'rsync', ['-a', '.', versionedPath]
      , 'Failed to move files from temp to versioned directory' ]
      # Success output
      [ 'Successfully moved files from temp to versioned directory' ]
    )# }}}

  desc 'Symlink new version'
  task 'symlink-live', [
    'version:load-proc'
    'deploy:create-versioned-dir'
    'deploy:move-files'
  ], async: true, ->
    title 'Attempting to make symbolic links'# {{{
    chain\
    ( [ 'rm', [livePath]
      , "Failed to remove old live path symlink at #{livePath}"
      , (-> !fs.existsSync livePath) ]
      [ 'ln', ['-s', versionedPath, livePath]
      , "Failed to make symlink #{livePath} -> #{versionedPath}" ]
      # Success output
      [ 'Successfully symlinked live path to new version' ]
    )# }}}

