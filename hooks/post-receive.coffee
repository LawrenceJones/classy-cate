#!/usr/bin/env coffee

child_process = require 'child_process'
[exec, spawn] = [child_process.exec, child_process.spawn]
fs = require 'fs'
path = require 'path'

# Create build domain
build = (require 'domain').create()

# Git remote
REMOTE = process.cwd()

# Create tmp directory name
# Ex. /tmp/project-1401134733128
tmpDir = path.join '/', 'tmp', "#{process.cwd().split('/').pop()}-#{Date.now()}"

# Global declares
gitOut = ''
branch = null

# Simple log with prefix of |----
log = (msg...) ->
  console.log "|---- #{msg.join '     '}"

# Prompt output $ cmd arg arg
prompt = (cmd) ->
  console.log "        $ #{cmd}"

# Trigger a build failure
fail = (msg) ->
  if msg instanceof String
    msg = '\n'+msg.split('\n').join('       ')+'\n'
  throw new Error msg

# Verbose exec, echos command
execv = (cmd, cb) ->
  prompt cmd
  exec cmd, cb

# Verbose spawn command
spawnv = (cmd, args, opt, cb) ->
  prompt "#{cmd} #{args.join ' '}\n"
  if !opt? then cb = opt; opt = {}
  prog = spawn cmd, args, opt
  live = (stream) -> prog[stream].pipe process[stream]
  ['stdout', 'stderr'].map live
  prog.on 'exit', (code) ->
    console.log()
    cb?(code)

# Makes temporary directory for git tree
makeTmpDir = (cb) ->
  log "Making temporary directory in #{tmpDir}"
  execv "mkdir #{tmpDir}", (err, stdout, stderr) ->
    fail err.message if err?
    cb?()

removeTmpDir = (cb) ->
  if !fs.existsSync tmpDir then return cb?()
  log "Removing temporary directory at #{tmpDir}"
  execv "rm -rf #{tmpDir}", (err, stdout, stderr) ->
    fail 'Failed to remove temporary directory' if err?
    cb?()

# Clones git repo into tmpDir and checks out the master
cloneCommit = (cb) ->
  log 'Cloning current HEAD into temporary directory'
  execv "git clone #{REMOTE} #{tmpDir}", (err, stdout, stderr) ->
    fail err if err?
    execv 'git checkout master', (err, stdout, stderr) ->
      fail err.message if err?
      cb?()

# Runs npm in project
runNpmStart = (cb) ->
  log 'Running projects start script'
  spawnv 'npm', ['start'], cwd: tmpDir, (err) ->
    fail err if err?
    cb?()

# Start post-receive
build.run ->
  do console.log
  makeTmpDir ->
    cloneCommit ->
      runNpmStart ->
        log 'Completed deploy!'

# Catches error in receive
build.on 'error', (err) ->
  log 'Post-receive failed with error: ', err
  removeTmpDir ->
    do console.log
    process.exit 1



