#!/usr/bin/env coffee
fs        = require 'fs'
spawn     = (require 'child_process').spawn
sSplitter = require 'stream-splitter'
$q         = require 'q'

# Log Styles ###########################################
 
(styles = {
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
log = (child) ->
  startLog = (stream) ->
    sstream = stream.pipe sSplitter '\n'
    sstream.encoding = 'utf8'
    def = $q.defer()
    sstream.on 'token', (token) ->
      process.stdout.write "    #{token}\n"
    sstream.on 'done', -> def.resolve()
    def.promise
  ($q.all [child.stdout, child.stderr].map startLog)
    .then -> do console.log

# Build Helpers ########################################

# Halts build chain
fail = (msg) ->
  console.error " ! #{msg}\n".red
  throw new Error msg

# Logs child process exit
handleExit = (child, msgSucc, msgFail) ->
  child.on 'exit', (code) ->
    if code is EXIT_SUCCESS = 0
      console.log msgSucc
      do complete
    else fail msgFail.replace /CODE/g, code
  
# Build Tasks ##########################################

# Spawns an npm process with the install flag
desc 'Install required npm modules'
task 'install-npm-depends', [], ->
  console.log '\n\n > Attepting to install dependencies via npm\n'.white
  npm = spawn 'npm', ['install']
  log npm
  handleExit\
  ( npm
  , '\n + Successfully installed npm dependencies'.green
  , 'npm exited with error code CODE' )

desc 'Loads properties file'
props = versionedPath = livePath = null # declare
task 'load-props', ['install-npm-depends'], ->
  console.log '\n\n > Attempting to read in build properties\n'.white
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

  console.log '\n + Successfully read properties'.green
  do complete

desc 'Create versioned site directory'
task 'create-versioned-dir', ['load-props'], ->
  console.log '\n\n > Attempting to create versioned directory\n'.white
  fs.mkdir versionedPath, (err) ->
    if err? then fail 'Failed to create versioned directory'
    console.log '\n + Successfully created versioned directory'.green
    do complete

desc 'Move files to location'
task 'move-files', ['load-props', 'create-versioned'], ->
  console.log '\n\n > Attempting to move files'.white
  exec "rsync -a . #{versionedPath}", (err, stdout, stderr) ->
    if err? then fail 'Failed to move files'
    console.log '\n + Successfully moved files'.green
    do complete

desc 'Symlink new version'
task 'symlink-live', ['load-props', 'create-versioned-dir', 'move-files'], ->
  console.log '\n\n > Attempting to make symbolic links'.white
  console.log '    Removing old symlink...'
  fs.unlink livePath, (err) ->
    if err? then fail 'Failed to remove old live path symlink'
    console.log '    Creating new symlink...'
    fs.symlink versionedPath, livePath, (err) ->
      if err? then fail 'Failed to create new symlink'
      console.log '\n + Successfully symlinked livepath'.green
      do complete

desc 'Kickstarts site into production'
task 'default', ['load-props', 'create-versioned-dir', 'move-files', 'symlink-live'], ->
  console.log '\n\n > Attempting to push to launch site into production'
  do complete # TODO - Complete


