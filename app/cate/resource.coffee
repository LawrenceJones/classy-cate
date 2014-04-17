$ = require 'cheerio'
$q = require 'q'
http = require 'http'
request = require 'request'

module.exports = class CateResource

  @cateResource: true
  @termDates: new Object()

  # Initialises a data object and then proxies all
  # arguments along to a parsing function.
  constructor: (@req, @$page) ->
    @data = {}
    @parse.apply @, Array::slice.call(arguments, 1)

  parse: ->
    throw new Error 'Override the parse method!!'

  # Creates an authentication object from a request handle.
  @createAuth: (req) ->
    user: req.user.user
    pass: req.user.pass
    sendImmediately: true

  # Loads html into a jquery wrapper.
  @jquerify: (body) ->
    $.load body, lowerCaseTags: true

  # Makes request without authentication using node
  # http library rather than request. Some websites
  # seem to be rejected by request, ie term dates.
  @getPlain: (method, host, path) ->
    deferred = $q.defer()
    options =
      hostname: host
      method: 'GET'
      port: 80, path: path
    req = http.request options, (res) ->
      res.setEncoding 'utf8'
      body = ''
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', -> deferred.resolve body
    req.on 'error', (e) ->
      deferred.reject e.message
    req.end()
    deferred.promise

  # If url is already known, then this can be used, given
  # a request handle with credentials, to pull data directly
  # from that url and run parser.
  @scrape: (req = params: {}, url) ->
    req.params.url = url
    options = url: url, auth: @createAuth req
    request options, (err, data, body) =>
      if err? then return deferred.reject err
      $page = @jquerify(body) 'body'
      cate_res = new @ req, $page
      res?.json? cate_res.data
      deferred.resolve cate_res.data
    deferred = $q.defer()
    deferred.promise

  # GET handler for requesting index of information.
  @get: (req, res) ->
    if not @cateResource
      throw Error 'Must be called from CateResource'
    scrape = @scrape req, @url req
    scrape.then (data) ->
      res.json data
    scrape.catch (err) ->
      console.error err
      res.send 500

