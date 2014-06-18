$q = require 'q'
jayschema = new (JaySchema = require 'jayschema')

ParserTools = require 'app/parsers'
HTMLParser = ParserTools.HTMLParser
proxy = new (HTTPProxy = ParserTools.HTTPProxy)(HTMLParser)

describe 'HTTPProxy', ->

  describe 'should generate valid request option object', ->

    [url, login, pass] = ['www.google.com', 'login', 'pass']

    obfuse = (str) ->
      if 'USER_CREDENTIALS' then user: login, pass: pass

    plain = user: login, pass: pass

    exp =
      url: url
      auth:
        user: login, pass: pass
        sendImmediately: true

    it 'for an obfusificated user credentials (jwt)', ->
      proxy.makeOptions url, obfuse
      .should.deep.equal exp

    it 'for a standard {user: user, pass: pass} hash', ->
      proxy.makeOptions url, plain
      .should.deep.equal exp

