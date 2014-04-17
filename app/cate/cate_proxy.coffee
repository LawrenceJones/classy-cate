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
  makeRequest: (query, user) ->

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



