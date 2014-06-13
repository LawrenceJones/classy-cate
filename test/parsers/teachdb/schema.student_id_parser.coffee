# JSON Schema for app/parsers/teachdb/student_id_parser

metaSchema =
  type: 'object'
  required: ['login', 'tid']
  additionalProperties: false
  properties:
    login: type: 'string'
    tid: type: ['integer', 'null']

module.exports = studentIDSchema =
  type: 'object'
  additionalProperties: false
  properties:
    _meta: metaSchema

