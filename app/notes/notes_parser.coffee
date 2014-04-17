CateParser = require '../cate/cate_parser'

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

# Given a jQuery $row, returns the link for that note.
getNoteLink = ($row, q) ->
  $link = $row.find('td:eq(1) a')
  if linkIsLocal($link)
    return $link.attr('href')
  else if linkIsRemote($link)
    identifier = $link.attr('onclick').match(/clickpage\((.*)\)/)[1]
    "showfile.cgi?key=#{q.year}:#{q.code}:#{identifier}::NOTES"

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
      notes.push
        type:   getNoteType  $(row)
        title:  getNoteTitle $(row)
        link:   getNoteLink  $(row), @query

    # Return extracted data
    moduleID:    moduleID
    moduleName:  moduleName
    notes:       notes
    year:        @query.year
    code:        @query.code

  # Generate notes url on the academic year and notes code,
  # the unique id that links against the notes collection.
  @url: (query) ->
    code = query.code
    year = query.year  ||  @defaultYear()
    if not (code && year)
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/notes.cgi?key=#{year}:#{code}"

