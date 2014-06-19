$q = require 'q'
request = require 'request'
process.setMaxListeners 0
$q.longStackSupport = true

HTTPProxy = require 'app/proxies/http_proxy'

module.exports = class HTTPIndexedProxy extends HTTPProxy

  constructor: (@Parser, @IndexParser) ->
    if not @Parser.HTML_PARSER and @IndexParser.HTML_PARSER
      throw Error """
      Incorrect arguments supplied to HTTPIndexedProxy constructor.
      All arguments must be HTMLParsers.
      """

  # Runs the first query through the INDEXER, which resolves
  # a query that can then be passed through the main PARSER.
  #
  # Example.
  #
  #   StudentIDParser >> StudentParser
  #
  # As the ID resolves the tid, which can be used as an index
  # into StudentParser.
  makeRequest: (query, user, delay = 0, salt = 0) ->
    [index, parse] = [@IndexParser, @Parser]
    @runParser index, query, user
    .then (secondKey) =>
      @runParser parse, secondKey, user


