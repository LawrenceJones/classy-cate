request = require 'request'
cheerio = require 'cheerio'
module.exports ?= {}

parseNotes = ($, $page) ->

  get_note_rows = (html) ->
    rows = html.find('table [cellpadding="3"] tr')
    ($(r) for r in rows[3..])

  get_note_type = (row) ->
    link = $(row.elemAt('td', 1).find('a'))
    if link_is_local(link)
      return "resource"
    else if link_is_remote(link)
      return "url"

  get_note_title = (row) ->
    note_title = row.elemAt('td', 1).text()

  get_note_link = (row) ->
    link = $(row.elemAt('td', 1).find('a'))
    if link_is_local(link)
      return link.attr('href')
    else if link_is_remote(link)
      identifier = link.attr('onclick').match(/clickpage\((.*)\)/)[1]
      return "showfile.cgi?key=2012:3:#{identifier}:c3:NOTES:peh10"
    return null

  link_is_remote = (link) ->
    link.attr('onclick')?
  link_is_local = (link) ->
    link.attr('href')? && link.attr('href') != ''

  notes = []
  for row in get_note_rows $page
    notes.push {
      type:  get_note_type row
      title: get_note_title row
      link:  get_note_link row
    }
  return { notes: notes }


# GET /api/notes
exports.getNotes = (req, res) ->
  options =
    url: 'https://cate.doc.ic.ac.uk/notes.cgi?key=2013:19:3:c2:new:lmj112'
    auth: req.creds
  request options, (err, data, body) ->
    $ = cheerio.load body, {
      xmlMode: true
      lowerCaseTags:true
    }
    res.json parseNotes $, $ 'body'
 
