# Verifies there is no json seed for the desired route. If there is, then serves
# the seed.

fs     = require 'fs'
path   = require 'path'

module.exports = (opts) -> (req, res, next) ->

  seedDir = opts.seedDir || './public/json'
  prefix  = opts.prefix || ''

  file = (prefix + req.url)
    .replace /^\//, ''
    .replace /\//g, '.'
  file = path.join seedDir, "#{file}.#{req.method.toLowerCase()}.json"

  fs.exists file, (seedExists) ->
    if seedExists
      console.log 'SEED!'
      res.json JSON.parse fs.readFileSync(file, 'utf8')
    else do next
    
