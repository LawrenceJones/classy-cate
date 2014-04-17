$q = require 'q'
request = require 'request'

# Class for the basic CATe proxy. All instances will own a parser,
# which will facilitate parsing the html source that this class
# will fetch.
#
# User credentials ARE handled here, and care is required.
module.exports = class CateProxy

  # Constructed using a CateParser class
  constructor: (@Parser) ->
    if not @Parser.CATE_PARSER
      throw Error "Invalid CateParser object: #{@Parser}"

  # Will generate a url from the parser, then using the supplied
  # USER function, will access the credentials and make the request.
  #
  # Returns a promise that is resolved with the parsed data.
  # If query if an ARRAY, will process each query individually.
  makeRequest: (query, user) ->

    # If query is an array then map over and generate a collective promise
    if query instanceof Array
      return $q.all(query.map (q) => @makeRequest q, user)

    # Retrieve the user credentials from the jwt store
    auth = user('USER_CREDENTIALS')
    auth.sendImmediately = true
    options =
      url:  (url = @Parser.url query)
      auth: auth

    # Make request, feed result through parser and resolve promise.
    request options, (err, data, body) =>
      throw err if err?
      deferred.resolve @Parser.parse url, query, body

    return (deferred = $q.defer()).promise

  # Takes user login and password, resolves promise on whether
  # CATE has accepted the credentials.
  @auth: (user, pass) ->
    options =
      url: 'https://cate.doc.ic.ac.uk'
      auth:
        user: user, pass: pass
        sendImmediately: true
    request options, (err, data, body) ->
      throw 401 if data.statusCode is 401
      deferred.resolve data.statusCode
    (deferred = $q.defer()).promise



