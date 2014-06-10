HTMLParser = require '../html_parser'

# Parses Givens pages of CATe.
# Accepts data from ~/given.cgi?key=<YEAR>:<ACCESS>:<CODE>:<CLASS>
module.exports = class GivensParser extends HTMLParser

  # Extracts givens data from a givens page, including various
  # types of document.
  extract: ($) ->

    # Fetch ID and name of module
    try
      [moduleID, moduleName] = HTMLParser.extractModule $
    catch err then return err

    # Store categories inside this array
    categories = new Array()
    
    [exerciseID, exerciseTitle] = [null, null]
    # Extract exercise ID and title
    $('table:eq(2) tr').each ->
      [label, value] = $(this).find('td').map -> $(@).text()
      if /Title/.test label
        exerciseTitle = value
      else if /Number/.test label
        exerciseID = value
      else if /Type/.test label
        exerciseID += ":#{value}"

    # Iterate over the givens tables
    $('table [cellpadding="3"]')[2..].each (i, e) ->
      category = type: null, givens: []
      if $(this).find('tr').length > 1 # Only process tables with content
        category.type = $(this).closest('form').find('h3 font').html()[..-2]
        $rows = $(this).find('tr')[1..]
        $rows.each ->
          if ($cell = $(this).find('td:eq(0) a')).attr('href')?
            category.givens.push
              title: $cell.html()
              link:  "#{HTMLParser.CATE_DOMAIN}/#{$cell.attr('href')}"
        categories.push category

    # Return an array of categories, each element containing a type and rows
    # categories = [ { type = 'TYPE', givens = [{title, link}] } ]
    moduleID:      moduleID
    moduleName:    moduleName
    exerciseID:    exerciseID
    exerciseTitle: exerciseTitle
    categories:    categories
    year:          @query.year
    code:          @query.code
    klass:         @query.klass

  # Generate notes url on the academic year and givens code,
  # the unique id that links against the exercise.
  # Givens vary by class, hence required.
  @url: (query) ->
    klass = query.class
    code  = query.code
    year  = query.year  ||  @defaultYear()
    if not (klass && code && year)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/given.cgi?key=#{year}::#{code}:#{klass}"

