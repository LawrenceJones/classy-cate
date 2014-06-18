HTMLParser = require '../html_parser'

# Teachdb provides a general indexing function into their tables.
# This is a class that provides the ability to parse from any teachdb
# search the unique tid of the desired target.
# Accepts data from ~/db/viewtab?table=<TABLE>&<ARG_KEY>=<LOGIN>
module.exports = class TIDParser extends HTMLParser

  # Extracts data from html. Returns tid: null if unsuccessful.
  extract: ($) ->
    try
      $table = $('table[width="95%"][border="1"]')
      $idCell = $table.find('tr:gt(1) td[bgcolor="#efefef"]:eq(0)')

      uri = $idCell.find('a:eq(0)').attr 'href'
      [table, _tid] = uri?.match(/^viewrec\?table=([^&]+)&id=(\d+)$/)[1..2]
      tid = parseInt _tid, 10
    catch err

    tid: tid ? null

  # Will generate a url from the following parameters...
  # Eg. {argKey: 'arg1', value: 'lmj112', table: 'Student'}
  @url: (query) ->
    argKey = query.argKey
    value = query.value
    table = query.table
    if not (argKey && value && table)
      throw Error 'Missing login query parameters'
    "#{@TEACH_DOMAIN}/db/viewtab?table=#{table}&#{argKey}=#{value}"

