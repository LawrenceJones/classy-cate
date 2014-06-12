# JSON Schema for app/parsers/teachdb/student_parser

metaSchema =
  type: 'object'
  required: ['login', 'tid']
  additionalProperties: false
  properties:
    login: type: 'string'
    tid: type: 'integer'

courseSchema =
  type: 'object'
  additionalProperties: false
  properties:
    cid: type: 'string'
    name: type: 'string'
    eid: type: ['string', 'null']
    terms:
      type: 'array'
      items: type: 'integer'
    classes:
      type: 'array'
      items: type: 'string'

enrolmentSchema =
  type: 'object'
  additionalProperties: false
  properties:
    year: type: 'integer'
    class: type: 'string'

userSchema =
  type: 'object'
  additionalProperties: false
  properties:
    tid: type: 'integer'
    validFrom: type: 'integer'
    validTo: type: 'integer'
    login: type: 'string'
    email: type: 'string', pattern: '^[^@]+@[^.]+\.[^@]+$'
    fname: type: 'string'
    lname: type: 'string'
    salutation: type: 'string'
    origin: type: 'string', pattern: '^[A-Z]+$'
    entryYear: type: 'integer'
    url: type: 'string'
    cand: type: 'string', pattern: '^[0-9]+$'
    courses:
      type: 'array'
      items: courseSchema
    enrolment:
      type: 'array'
      items: enrolmentSchema


module.exports = studentSchema =
  type: 'object'
  additionalProperties: false
  properties:
    _meta: metaSchema
    user: userSchema

