$q = require 'q'
creds = require 'test/server/creds'
jayschema = new (JaySchema = require 'jayschema')

ParserTools = require 'app/parsers'
HTTPProxy = ParserTools.HTTPProxy

# Given a jayschema, remote resource proxy and query parameters,
# will attempt to make request and validate against schema.
# Returns promise that is resolved if the instance checks out.
validate = (schema, Proxy, query) ->
  Proxy.makeRequest query, creds
  .then (json) ->
    jayschema.validate json, schema
    return json
  .catch (errs) ->
    console.log errs
    errors = {}
    (errors[err.desc] ?= []).push err for err in errs
    console.log desc for desc in Object.keys errors
    throw Error
  
describe 'Parsers', ->

  describe 'CATe', ->

    describe 'TimetableParser', ->

      if process.env.API then describe '#extract', ->

        ttSchema = require 'test/server/parsers/cate/schema.timetable_parser.coffee'
        TimetableProxy = new HTTPProxy ParserTools.cate.TimetableParser
        queryPeriod = (period) ->
          query = {}
          query[k] = v for own k,v of creds.opt
          query.period = period; query

        [1..6].map (p) ->
          it "should validate JSON for period #{p}", ->
            validate ttSchema, TimetableProxy, queryPeriod(p)

  describe 'teachdb', ->

    describe 'StudentIDParser', ->

      sidSchema = require 'test/server/parsers/teachdb/schema.student_id_parser.coffee'
      StudentIDProxy = new HTTPProxy ParserTools.teachdb.StudentIDParser
      tids = [
        ['lmj112', 14678]
        ['thb12', 14658]
        ['nonvalid', null]
      ]

      tids.map (elem) ->
        [login, exp] = elem
        it "should resolve #{login} to tid = #{exp}", (done) ->
          validate(sidSchema, StudentIDProxy, login: login)
          .then (json) ->
            expect(json.tid).to.equal exp; do done
          .catch (err) ->
            console.log err

            

    describe 'StudentParser', ->

      StudentParser = ParserTools.teachdb.StudentParser
      StudentProxy = new HTTPProxy StudentParser
      courses = [
        {classes: ['c1', 'j1', 'c3']}
        {classes: ['c1', 'j2']}
        {classes: ['c1']}
        {classes: ['c2', 'j2']}
        {classes: ['c2']}
      ]
      
      if not process.env.UNIT_ONLY then describe '#extract', ->

        studentSchema = require 'test/server/parsers/teachdb/schema.student_parser.coffee'
        it "should validate JSON for tid #{creds.opt.tid}", (done) ->
          validate studentSchema, StudentProxy, tid: creds.opt.tid
          .then (-> do done), done

      describe '#estimateYearStudied', ->
        estimateYears = StudentParser._helpers.estimateYearsStudied
        it 'should return 1 for 2012 entry, on 12 Aug 2013', ->
          estimateYears 2012, new Date('12 Jan 2013')
          .should.equal 1
        it 'should return 2 for 2012 entry, on 10 Sept 2013', ->
          estimateYears 2012, new Date('10 Sept 2013')
          .should.equal 2
        it 'should return 1 for 2012 entry, on 5 Aug 2012', ->
          estimateYears 2012, new Date('5 Aug 2012')
          .should.equal 1

      describe '#combinations', ->
        it "should return [['A','B'],['A','C'],['B','C']] when choosing 2 from ['A','B','C']", ->
          combos = StudentParser._helpers.combinations ['A','B','C'], 2
          combos.should.deep.equal [['A','B'], ['A','C'], ['B','C']]

      describe '#findLongestRuns', ->
        findLongestRuns = StudentParser._helpers.findLongestRuns
        runs = findLongestRuns courses
        
        it "should discount classes that don't appear consequtively", ->
          runs.should.not.have.key 'j2'

        it 'should accurately count successive classes', ->
          runs.should.deep.include c1: 3, c2:2

      describe '#bestGuessClasses', ->
        guesses = StudentParser._helpers.bestGuessClasses courses, 2012, new Date('12 June 2014')
        it 'should guess c1 and c2', ->
          guesses.should.deep.equal ['c1', 'c2']

      describe '#url', ->
        it 'should generate correct url', ->
          StudentParser.url tid: 123456
          .should.equal 'https://teachdb.doc.ic.ac.uk/db/All/viewrec?table=Student&id=123456'

      


