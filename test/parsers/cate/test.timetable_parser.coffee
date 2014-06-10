should = require 'should'

JaySchema = require 'jayschema'
js = new JaySchema

HTTPProxy = require 'app/parsers/http_proxy'
TimetableParser = require 'app/parsers/cate/timetable_parser'
TimetableProxy = new HTTPProxy TimetableParser

metaSchema =
  type: 'object'
  required: ['year', 'period', 'start', 'end', 'title']
  additionalProperties: false
  properties:
    year: type: 'integer'
    period: type: 'integer'
    start: type: 'integer'
    end: type: 'integer'
    title: type: 'string'

notesSchema =
  type: ['object', 'null']
  additionalProperties: false
  properties:
    year: type: 'integer'
    code: type: 'integer'
    period: type: 'integer'

givensSchema =
  type: ['object', 'null']
  additionalProperties: false
  properties:
    year: type: 'integer'
    period: type: 'integer'
    code: type: 'integer'
    class: type: 'string'


exerciseSchema =
  type: 'object'
  additionalProperties: false
  properties:
    eid: type: 'integer'
    type: type: 'string'
    name: type: 'string'
    start: type: 'integer'
    end: type: 'integer'
    handin: type: ['string', 'null']
    spec: type: ['string', 'null']
    mailto: type: ['string', 'null']
    givens: givensSchema

courseSchema =
  type: 'object'
  additionalProperties: false
  properties:
    cid: type: 'string'
    name: type: 'string'
    notes: notesSchema
    exercises:
      type: 'array'
      items: exerciseSchema

ttSchema =
  type: 'object'
  additionalProperties: false
  properties:
    _meta: metaSchema
    courses:
      type: 'array'
      items: courseSchema

describe 'timetable parser', ->

  it 'produces schema validated json', (done) ->
    creds = require 'test/creds'
    req = TimetableProxy.makeRequest creds.opt, creds
    req.then (tt) ->
      js.validate tt, ttSchema, (errs) ->
        errs?.should.fail 'failed to validate schema'
        do done
    req?.catch (err) ->
      should.fail 'failed to make connection'
    


