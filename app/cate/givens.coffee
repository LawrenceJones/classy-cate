$ = require 'cheerio'
CateResource = require './resource'

DOMAIN = 'https://cate.doc.ic.ac.uk'

module.exports = class Givens extends CateResource

  parse: ->

    categories = []
    # Select the tables
    $tables = @$page.find('table [cellpadding="3"]')[2..]
    $tables.each ->
      category = {}
      if $(this).find('tr').length > 1  # Only process tables with content
        category.type = $(this).closest('form').find('h3 font').html()[..-2]
        rows = $(this).find('tr')[1..]
        category.givens = []
        for row in rows
          if (cell = $(row).elemAt('td', 0).find('a')).attr('href')?
            category.givens.push {
              title : cell.html()
              link  : cell.attr('href')
            }
        categories.push category

    # Return an array of categories, each element containing a type and rows
    # categories = [ { type = 'TYPE', givens = [{title, link}] } ]
    @data = categories

  # Links may not be prefixed with cate.doc, fix this.
  @scrape: (req, url) ->
    if not /cate\.doc\./.test url
      url = "#{DOMAIN}/#{url}"
    super req, url

  @url: (req) ->
    "#{DOMAIN}/#{req.query.link}"

