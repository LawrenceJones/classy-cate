$q = require 'q'
request = require 'request'
process.setMaxListeners 0
$q.longStackSupport = true

HTMLParser = require 'app/parsers/html_parser'

module.exports = class HTTPProxy

  # Construct with a collection of HTMLParsers to be processed in the
  # order given. These are to be chained together to allow a single
  # promise to be returned for successful transmission.
  constructor: (@parsers...) ->
    for Parser in @parsers
      if not Parser.HTML_PARSER then throw Error """
      Incorrect arguments supplied to HTTPProxy constructor.
      All arguments must be HTMLParsers.
      """

  # Runs through the chain of the proxy calls in sequence, passing
  # the result of each subsequent call in as the query to run the
  # next proxy against.
  #
  # Example is a chain of StudentIDParser StudentParser.
  #
  # First StudentIDParser will be run against the inital query, which
  # we can say is {login: 'lmj112'}. This is then resolved using the ID
  # parser to produce a {tid: 14678} object, which is then chained
  # once more to the StudentProxy.
  makeRequest: (query, user, delay = 0, salt = 0) ->

    @parsers.reduce(
      (prev, Parser) =>
        prev.then (result) =>
          @runParser Parser, result, user
      @runParser @parsers[0], query, user
    )

  # Dispatches the request to scrap from our Proxy to our remote,
  # and uses the PARSER to extract data from the response.
  runParser: (Parser, query, user) ->
    $q.fcall =>
      url = Parser.url query
      @reqcall request, @makeOptions url, user
      .then (data) ->
        Parser.parse url, query, data
    
  # Returns an object suitable for use with the Request library.
  # Exp format.
  #
  #   url: url
  #   auth:
  #     user: 'lmj112', pass: 'password'
  #     sendImmediately: true
  #
  makeOptions: (url, user) ->
    auth = user ? {}
    auth.sendImmediately = true
    reqOptions = url: url, auth: auth

  # Adaption of Q's nfcall for selecting the third of the callback
  # arguments.
  reqcall: (func, args...) ->
    def = $q.defer()
    func args..., (err, res, body) ->
      if err then def.reject err
      else def.resolve code: res.statusCode, body: body
    def.promise

