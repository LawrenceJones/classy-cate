$ = require 'cheerio'
request = require 'request'

module.exports = class CateResource

  @cateResource: true

  constructor: (@$page) ->
    @data = {}
    @parse.apply @, arguments

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

  # GET handler for requesting information
  @get: (req, res) ->
    if not @cateResource
      throw Error 'Must be called from CateResource'
    options =
      url: @url req
      auth: @createAuth req
    request options, (err, data, body) =>
      $page = @jquerify(body) 'body'
      cate_res = new @ $page
      res.json cate_res.data

