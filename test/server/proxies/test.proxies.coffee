$q = require 'q'
jayschema = new (JaySchema = require 'jayschema')

ParserTools = require 'app/parsers'
HTMLParser = ParserTools.HTMLParser
proxy = new (HTTPProxy = ParserTools.HTTPProxy)(HTMLParser)

describe 'HTTPProxy', ->

  describe 'should generate valid request option object', ->

    [url, login, pass] = ['www.google.com', 'login', 'pass']

    plain = user: login, pass: pass

    exp =
      url: url
      auth:
        user: login, pass: pass
        sendImmediately: true

    it 'for a standard {user: user, pass: pass} hash', ->
      proxy.makeOptions url, plain
      .should.deep.equal exp


  describe 'StudentProxy', ->

    StudentProxy = require 'app/proxies/teachdb/student_proxy'

    it 'should get user for lmj112', ->
      StudentProxy.makeRequest login: 'lmj112', creds
      .should.eventually.include
        login: 'lmj112'
        email: 'lawrence.jones12@imperial.ac.uk'

