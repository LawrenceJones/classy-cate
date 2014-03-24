# Concatenates full angular app into a single app.js
# TODO - refactor into midware

fs     = require 'fs'
path   = require 'path'
coffee = require 'coffee-script'

# Collects all coffeescript files in directory dpath
globCoffee = (dpath) ->
  [files,dirs] = fs.readdirSync(dpath).reduce ((a,c) ->
    fpath = path.join dpath, c
    a[+fs.statSync(fpath).isDirectory()].push fpath; a), [[],[]]
  csrc = files.filter (f) -> /^(.+)\.(coffee|js)$/.test f
  csrc.concat dirs.map(globCoffee)...

# Export the get request handler
module.exports = (options) ->
  return (req, res) ->
    res.setHeader 'Content-Type', 'text/javascript'
    res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
    src = globCoffee(options.angularPath)
      .map (f) -> coffee.compile fs.readFileSync(f, 'utf8')
      .reduce (a,c) -> a + c
    res.send src

