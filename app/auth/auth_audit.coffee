fs = require 'fs'
path = require 'path'
hljs = require 'highlight.js'
config = require '../etc/config'

CRED_REX = new RegExp 'USER_CREDENTIALS'

# Collect all coffeescript files
globCoffeeScript = (dir = config.paths.app_dir, files = []) ->
  for f in fs.readdirSync dir
    f = path.join dir, f
    if fs.statSync(f).isDirectory()
      globCoffeeScript f, files
    else if !/auth\/auth_audit\.coffee$/.test f
      files.push f if /\.coffee$/.test f
  return files

# Find files with USER_CREDENTIALS
findCredentialAccesses = (files) ->
  files
    .map (f) -> file: f, src: fs.readFileSync f, 'utf8'
    .filter (f) -> CRED_REX.test f.src
    .map (f) ->
      f.lines = []
      for line,i in f.src.split '\n'
        f.lines.push i if CRED_REX.test line
      f
        
# GET /audit
# Route for the security audit result
module.exports = (req, res) ->
  hits = findCredentialAccesses globCoffeeScript()
  auth = path.join config.paths.app_dir, 'auth', 'auth_router.coffee'
  # Include the auth_router
  hits.push
    file: auth, src: fs.readFileSync auth, 'utf8'
  hits.map (h) ->
    h.file = h.file.match(/\/app\/.*/)[0]
  res.json hits

