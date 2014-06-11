# JSON Schema for app/parsers/cate/timetable_parser

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

module.exports = ttSchema =
  type: 'object'
  additionalProperties: false
  properties:
    _meta: metaSchema
    courses:
      type: 'array'
      items: courseSchema

