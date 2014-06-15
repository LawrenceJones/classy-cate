HTMLParser = require '../html_parser'

# Parses student teachdb table ID
# Accepts data from ~/db/viewtab?table=Student&arg1=<LOGIN>
module.exports = class StudentIDParser extends HTMLParser

  # Extracts data from html. Returns tid: null if unsuccessful.
  extract: ($) ->
    
    FAIL = _meta: tid: null, login: @query.login

    $idCell =
      $('table[width="95%"][border="1"] tr:gt(1) td[bgcolor="#efefef"]:eq(0)')

    return FAIL if $idCell.length is not 1

    uri = $idCell.find('a:eq(0)').attr 'href'
    tid = uri?.match(/^viewrec\?table=Student&id=(\d+)$/)[1]

    return FAIL if !tid

    _meta:
      tid: parseInt tid, 10
      login: @query.login

  # Requires a student college login
  # Eg. {login: "lmj112"}
  @url: (query) ->
    login = query.login
    if not login? then throw Error 'Missing login query parameters'
    "#{@TEACH_DOMAIN}/db/viewtab?table=Student&arg1=#{login}"

