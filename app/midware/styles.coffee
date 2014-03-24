#!/usr/bin/env coffee
fs   = require 'fs'
path = require 'path'
sass = require 'node-sass'

compile = (styles_dir) ->
  fs.readdirSync(styles_dir).reduce ((a,c) ->
    if /\.scss$/.test c
      spath = path.join styles_dir, c
      a + sass.renderSync({file: spath, includePath: styles_dir}) + '\n'
    else a), ''

# Get route provider for the apps stylesheets
midware = (styles_dir) ->
  (req, res) ->
    res.setHeader 'Content-Type', 'text/css'
    res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
    res.send compile styles_dir

# If called as script
if not module.parent
  [dir, out] = process.argv[2..]
  fs.writeFileSync out, (compile dir), 'utf8'
else
  module.exports = midware


