CateParser = require '../cate/cate_parser'

# Parses module subscriptions from dbc.doc
# Accepts data from ~/internalreg/subscription.cgi?key=<YEAR>:none:<USER>
module.exports = class ModulesParser extends CateParser

  # Extracts subscription level for each module.
  extract: ($) ->
    subscribedModules = []
    $lvlCells = $('input[name^="level-"]')
    $lvlCells.map ->
      $row = $(this).parent().parent()
      $moduleCell = $row.find 'td:eq(1)'
      [_, code, title] = $moduleCell.text().match /(\d+)\s(.*)/
      subscribedModules.push
        code: code, title: title
        lvl: $(this).attr 'value'
    subscribedModules

  # Requires a specified year and user for whom to pull subscribed modules.
  # Eg. {year: 2013, user: 'lmj112'}
  @url: (query) ->
    year   = query.year || @defaultYear()
    user   = query.user
    if not (year && user)
      throw Error 'Missing query parameters'
    "#{@DBC_DOMAIN}/internalreg/subscription.cgi?key=#{year}:none:#{user}"

