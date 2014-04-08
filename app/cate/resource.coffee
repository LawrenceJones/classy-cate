$ = require 'cheerio'
$q = require 'q'
http = require 'http'
request = require 'request'

module.exports = class CateResource

  @cateResource: true
  @termDates: new Object()

  constructor: (@req, @$page) ->
    @data = {}
    @parse.apply @, Array::slice.call(arguments, 1)

  parse: ->
    throw new Error 'Override the parse method!!'

  @createAuth: (req) ->
    user: req.user.user
    pass: req.user.pass
    sendImmediately: true

  @jquerify: (body) ->
    $.load body, {
      lowerCaseTags: true
    }

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

  # GET handler for requesting index of information.
  @get: (req, res) ->
    if not @cateResource
      throw Error 'Must be called from CateResource'
    options =
      url: @url req
      auth: @createAuth req
    request options, (err, data, body) =>
      $page = @jquerify(body) 'body'
      cate_res = new @ req, $page
      res.json cate_res.data

