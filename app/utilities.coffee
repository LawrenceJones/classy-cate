# Useful utility helpers to augment typical js routines

# Adds eq-like selection.
cheerio = require 'cheerio'
cheerio::elemAt = (sel, i) ->
  (@find sel).eq i


# Allows pushing to an array if element is not already present.
Array::addUnique = (elem, eq = ((a,b) -> a == b)) ->
  found = false
  found |= eq _elem, elem for _elem in @
  @push elem if not found
