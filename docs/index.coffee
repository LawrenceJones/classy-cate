# A script that extends the power of apiary.io's blueprint language.
# To include files into the main apiary doc, use...
#
#     [INCLUDE path/to/file]
#
# To include a model, simply write...
#
#     [MODEL modelName](key)
#
# Where the modelName is the registered name of the model, given by
# the filename from ./models/fileName.coffee.
#
# All included files are pushed through the compiler.
#
# Output is made to the APIARY target.

tokens =
  include: '^( *)\\[INCLUDE\\s+([^\\]]+)\\]'     # [ws, path]
  model: '^(\\s*)\\[MODEL\\s+(\\w+)\\]\\(([^)]+)\\)'      # [ws, modelName, key]

fs = require 'fs'
path = require 'path'

LIB_DIR     = path.join __dirname, 'lib'
MODELS_DIR  = path.join __dirname, 'models'
ENTRY       = path.join LIB_DIR, 'grep-doc.apib'
APIARY      = path.join __dirname, '..', 'apiary.apib'

Models = new Object
for mpath in fs.readdirSync(MODELS_DIR).filter((n) -> /\.coffee$/.test n)
  model = require path.join MODELS_DIR, mpath
  Models[model.name] = model

makeWs = (n) ->
  [0..n].reduce ((a,c) -> a+' '), ''

# Given an object and key, will return the value of the field at the
# given key. Supports dot notation to suggest nesting of keys.
getKeyValue = (obj, key) ->
  crrt = obj
  for key in key.split('.')
    crrt = crrt?[key]
    return if not crrt?
  crrt

# Given the nested keys data from the compileModel process, along
# with the models list of labels, will index into the labels and
# return the label it believes is matching.
getLabel = (nestKeys, labels) ->
  keys = Object.keys(nestKeys).sort((a,b) -> a-b).map (k) -> nestKeys[k]
  for key in keys
    labels = labels?[key]
  labels if typeof labels == 'string'

# [MODEL modelName](key)
compileModel = (modelStr) ->
  [ws, name, mkey] = modelStr.match(RegExp(tokens.model))[1..]
  model = Models[name]
  json = getKeyValue(model, mkey)
  json = json?() ? json
  lines = JSON.stringify(json, undefined, 4).split /\n/g
  noLines = lines.length
  avg = 48 * Math.ceil (lines.reduce ((a,c) -> a+=(c.length/noLines)), 0)/48

  nestKeys = {}

  for line,i in lines
    max = Math.max avg, 16*Math.ceil(line.length/16)
    [ws,key] = line.match(/^(\s+)"([^"]+)":/)?[1..] ? [null,null]
    if key? then for own k,v of nestKeys
      delete nestKeys[k] if parseInt(k,10) > ws.length
    if key? and ws?
      nestKeys[ws.length] = key
      if (label = getLabel nestKeys, model.labels)?
        lines[i] = "#{line}#{makeWs(max-line.length)}      // #{label}"
  lines.reduce ((a,c) -> a+"    #{c}\n"), ''

# [INCLUDE filePath]
compileInclude = (includeStr) ->
  [ws, ipath] = includeStr.match(new RegExp(tokens.include))[1..]
  apibPath = path.join __dirname, "#{ipath}.apib"
  compile fs.readFileSync(apibPath, 'utf8').trim()

# Compiles the preprocessing directives MODEL and INCLUDE.
compile = (src) ->
  src
  .replace new RegExp(tokens.include, 'gm'), compileInclude
  .replace new RegExp(tokens.model, 'gm'), compileModel

# Writes the apiary to APIARY file
write = (out) ->
  fs.writeFileSync APIARY, out, 'utf8'

console.log 'Compiling apiary.apib...'
write compile(fs.readFileSync(ENTRY, 'utf8'))
console.log "Finished compilation to #{APIARY}"



  
