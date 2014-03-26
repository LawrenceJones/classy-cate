$ = require 'cheerio'
request = require 'request'

module.exports = class CateResource

  @cateResource: true

  constructor: (@$page) ->
    @data = {}
    do @parse

  parse: ->
    throw new Error 'Override the parse method!!'

  # GET handler for requesting information
  @get: (req, res) ->
    if not @cateResource
      throw Error 'Must be called from CateResource'
    options =
      url: @url req
      auth:
        user: req.user.user
        pass: req.user.pass
        sendImmediately: true
    request options, (err, data, body) =>
      $page = ($.load body, {
        xmlMode: true
        lowerCaseTags: true
      }) 'body'
      cate_res = new @ $page
      res.json cate_res.data

