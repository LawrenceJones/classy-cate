$q = require 'q'
request = require 'request'
process.setMaxListeners 0
$q.longStackSupport = true

HTMLParser = require 'app/parsers/html_parser'

module.exports = class HTTPProxy

  # Construct with a collection of HTMLParsers to be processed in the
  # order given. These are to be chained together to allow a single
  # promise to be returned for successful transmission.
  constructor: (@Parser) ->
    if not @Parser.HTML_PARSER then throw Error """
    Incorrect arguments supplied to HTTPProxy constructor.
    All arguments must be HTMLParsers.
    """

  # Runs the first request to parse.
  makeRequest: (query, user, delay = 0, salt = 0) ->
    @runParser @Parser, query, user

  # Dispatches the request to scrap from our Proxy to our remote,
  # and uses the PARSER to extract data from the response.
  runParser: (Parser, query, user) ->
    $q.fcall -> Parser.url query
    .then (url) =>
      @reqcall request, (@makeOptions url, user)
      .catch -> throw Error 401
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
    opt = url: url
    if user
      opt.auth = user
      opt.auth.sendImmediately = true
    opt

  # Adaption of Q's nfcall for selecting the third of the callback
  # arguments.
  # Resolves promise with a http status CODE and html BODY
  reqcall: (func, args...) ->
    $q.fcall ->
      def = $q.defer()
      func args..., (err, res, body) ->
        if err then def.reject err
        else def.resolve body
      def.promise

