$ = require 'cheerio'
CateResource = require './resource'

# Cate Module from database
mongoose = require 'mongoose'
CateModule = mongoose.model 'CateModule'

# Base domain
DOMAIN = 'https://cate.doc.ic.ac.uk'

# Determines locality of links.
link_is_remote = (link) ->
  link.attr('onclick')?
link_is_local = (link) ->
  link.attr('href')? && link.attr('href') != ''

# Given a jQuery $row, determines if the note is a resource
# or a url.
get_note_type = ($row) ->
  link = $($row.elemAt('td', 1).find('a'))
  if link_is_local(link)
    return 'resource'
  else if link_is_remote(link)
    return 'url'

# Extracts a note title from the jQuery $row.
get_note_title = ($row) ->
  $row.elemAt('td', 1).text()

# Given a jQuery $row, returns the link for that note.
get_note_link = ($row) ->
  link = $($row.elemAt('td', 1).find('a'))
  if link_is_local(link)
    return link.attr('href')
  else if link_is_remote(link)
    identifier = link.attr('onclick').match(/clickpage\((.*)\)/)[1]
    return "showfile.cgi?key=2012:3:#{identifier}:c3:NOTES:peh10"
  return null

module.exports = class Notes extends CateResource

  getNoteRows: ->
    rows = @$page.find('table [cellpadding="3"] tr')
    ($(r) for r in rows[3..])

  parse: ->
    notes = []
    for $row in @getNoteRows()
      notes.push {
        type:  get_note_type $row
        title: get_note_title $row
        link:  get_note_link $row
      }
    # Load the current payload into the database
    url = @req.params.link || @req.query.link
    CateModule.updateModuleNotes url, notes if url?
    @data = notes

  # Note links will typically be sourced from hyperlinks,
  # therefore if the url looks like it's not containing
  # cate.doc then adjust it accordingly.
  @scrape: (req, url) ->
    if not /cate\.doc\./.test url
      url = "#{DOMAIN}/#{url}"
    super req, url

  @url: (req) ->
    "#{DOMAIN}/#{req.query.link}"

