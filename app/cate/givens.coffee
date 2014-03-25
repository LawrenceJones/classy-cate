request = require 'request'
cheerio = require 'cheerio'
module.exports ?= {}

parseGivens = ($, $page) ->

  categories = []
  # Select the tables
  $page
    .find('table [cellpadding="3"]')[2..]
    .each ->
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
  return categories

# GET /api/givens
exports.getGivens = (req, res) ->
  options =
    url: 'https://cate.doc.ic.ac.uk/given.cgi?key=2013:3:574:c2:new:lmj112'
    auth: req.creds
  request options, (err, data, body) ->
    $ = cheerio.load body, {
      xmlMode: true
      lowerCaseTags:true
    }
    res.json parseGivens $, $ 'body'
