CateParser = require '../cate/cate_parser'
CATE_DOMAIN = CateParser.CATE_DOMAIN

# Determines locality of links.
linkIsRemote = ($link) ->
  $link.attr('onclick')?
linkIsLocal = ($link) ->
  $link.attr('href')? && $link.attr('href') != ''

# Given a jQuery $row, determines if the note is a resource
# or a url.
getNoteType = ($row) ->
  $link = $row.find 'td:eq(1) a'
  if linkIsLocal $link
    return 'resource'
  else if linkIsRemote $link
    return 'url'

# Extracts a note title from the jQuery $row.
getNoteTitle = ($row) ->
  $row.find('td:eq(1)').text()

# Extracts correct link parameters
jsLinkRex = /Temp = "(showfile\.cgi\?key=)(\d+):(\d+):"[^"]+":([^:]*):([^:]*)/

# Given a jQuery $row, returns the link for that note.
getNoteLink = ($, $row, q) ->
  extract = ($link) ->
    if linkIsLocal($link)
      $link.attr('href')
    else if linkIsRemote($link)
      identifier = $link.attr('onclick').match(/clickpage\((.*)\)/)[1]
      [showfile, year, period, _, keyword] =
        $('head').html().match(jsLinkRex)[1..]
      "#{showfile}#{year}:#{period}:#{identifier}:CLASS:#{keyword}:USER"
  $link = $row.find('td:eq(1) a')
  return "#{CATE_DOMAIN}/#{extract $link}"

# Parses the Notes page of CATe.
# Accepts data from ~/notes.cgi?key=<YEAR>:<CODE>
module.exports = class NotesParser extends CateParser

  # Extracts the notes data from a summary page.
  extract: ($) ->

    # Fetch ID and name of module
    try
      [moduleID, moduleName] = CateParser.extractModule $
    catch err then return err

    # Extract rows that represent notes
    notes = new Array()
    $rows = $('table [cellpadding="3"] tr')[3..]
    $rows.each (i, row) =>
      $row = $(row)
      
      # Strip out any
      # "Maintaining access to URL addresses is the responsibility of the owner."
      # lines which CATe has added.
      if $row.children('td').length === 1
        continue
      
      notes.push
        restype:  getNoteType  $row
        title:    getNoteTitle $row
        link:     getNoteLink  $, $row, @query

    # Return extracted data
    moduleID:    moduleID
    moduleName:  moduleName
    links:       notes
    year:        @query.year
    code:        @query.code
    period:      @query.period

  # Generate notes url on the academic year and notes code,
  # the unique id that links against the notes collection.
  @url: (query) ->
    code = query.code
    period = query.period
    year = query.year  ||  @defaultYear()
    if not (code && year && period)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/notes.cgi?key=#{year}:#{code}:#{period}" # Access lvl 3

