CateParser = require '../cate/cate_parser'

# Parses Givens pages of CATe.
# Accepts data from ~/given.cgi?key=<YEAR>:<ACCESS>:<CODE>:<CLASS>
module.exports = class GivensParser extends CateParser

  # Extracts givens data from a givens page, including various
  # types of document.
  extract: ($) ->

    # Fetch ID and name of module
    try
      [moduleID, moduleName] = CateParser.extractModule $
    catch err then return err

    # Store categories inside this array
    categories = new Array()

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
              link:  $cell.attr('href')
        categories.push category

    # Return an array of categories, each element containing a type and rows
    # categories = [ { type = 'TYPE', givens = [{title, link}] } ]
    moduleID:    moduleID
    moduleName:  moduleName
    categories:  categories
    year:        @query.year
    code:        @query.code
    klass:       @query.klass

  # Generate notes url on the academic year and givens code,
  # the unique id that links against the exercise.
  # Givens vary by class, hence required.
  @url: (query) ->
    klass = query.klass
    code  = query.code
    year  = query.year  ||  @defaultYear()
    if not (klass && code && year)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/given.cgi?key=#{year}::#{code}:#{klass}"

