$q = require 'q'
request = require 'request'
process.setMaxListeners 0

# Adaption of Q's nfcall for selecting the third of the callback
# arguments.
nf3call = (func, args...) ->
  def = $q.defer()
  func args..., (err, res, body) ->
    if err then def.reject err
    else def.resolve body
  def.promise

# Class for the basic HTTP proxy. All instances will own a parser,
# which will facilitate parsing the html source that this class
# will fetch.
#
# User credentials ARE handled here, and care is required.
module.exports = class HTTPProxy

  # Constructed using a HTMLParser class
  constructor: (@Parser) ->
    if not @Parser.HTML_PARSER
      throw Error "Invalid HTMLParser object: #{@Parser}"

  # Returns an object suitable for use with the Request library.
  # Exp format.
  #
  #   url: url
  #   auth:
  #     user: 'lmj112', pass: 'password'
  #     sendImmediately: true
  #
  makeOptions: (url, user) ->
    # Retrieve the user credentials from the jwt store, or if testing
    # and supplied as USER then user that.
    auth = user?('USER_CREDENTIALS') ? user ? {}
    auth.sendImmediately = true
    reqOptions = url: url, auth: auth

  # Will generate a url from the parser, then using the supplied
  # USER function, will access the credentials and make the request.
  #
  # Returns a promise that is resolved with the parsed data.
  # If query if an ARRAY, will process each query individually.
  #
  # DELAY is the amount of time to delay the request by. Used to
  # prevent contention for site target on large numbers of queries.
  #
  # SALT is used for multiple requests when they are better spread
  # randomly over a time period. Again, is optional. Used for past
  # paper scraping where +12 requests can cause congestion.
  makeRequest: (query, user, delay = 0, salt = 0) ->

    # If query is a promise, then first resolve.
    $q.when query, (query) =>

      # If query is an array then map over and generate a collective promise
      if query instanceof Array
        return $q.all query.map (q) =>
          @makeRequest q, user, (delay + Math.random()*salt)

      # Parse url from query
      url = @Parser.url query

      # Make request, feed result through parser and resolve promise.
      $q.delay(1000*delay).then =>
        nf3call request, @makeOptions url, user

      # Pass the data through the Parser instance
      .then (data) =>
        @Parser.parse url, query, data


