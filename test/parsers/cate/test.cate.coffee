should = require 'should'
creds = require 'test/creds'
jayschema = new (JaySchema = require 'jayschema')

ParserTools = require 'app/parsers'
HTTPProxy = ParserTools.HTTPProxy

validate = (schema, Proxy, query, done) ->
  req = Proxy.makeRequest query, creds
  req.then (json) ->
    jayschema.validate json, schema, (errs) ->
      errs?.should.fail 'failed to validate schema'
      do done
  req.catch (err) ->
    should.fail 'failed to make connection'
  
describe 'parsers', ->

  describe 'cate', ->

    describe 'timetable', ->

      ttSchema = require 'test/parsers/cate/schema.timetable_parser.coffee'
      TimetableProxy = new HTTPProxy ParserTools.cate.TimetableParser
      queryPeriod = (period) ->
        query = {}
        query[k] = v for own k,v of creds.opt
        query.period = period; query

      [1..6].map (p) ->
        it "validated period #{p}", (done) ->
          validate ttSchema, TimetableProxy, queryPeriod(p), done

      


