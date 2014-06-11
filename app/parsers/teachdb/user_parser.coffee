HTMLParser = require 'app/parsers/html_parser'

# Parses user data from a teachdb summary page.
# Accepts data from ~/db/All/viewrec?table=Student&id=<TID>
module.exports = class TimetableParser extends HTMLParser

  # Extracts user information from page
  extract: ($) ->
    user = 'lawrence'
    # Return parsed data
    _meta:
      tid: @query.tid
    user: user

  # Requires a teachdb user id into the All table.
  # Eg. {tid: 14678}
  @url: (query) ->
    tid = query.tid
    if not tid
      throw Error 'Missing query parameters'
    "#{@TEACHDB_DOMAIN}/db/All/viewrec?table=Student&id=#{tid}"

