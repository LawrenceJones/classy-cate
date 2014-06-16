# JSON Schema for app/parsers/teachdb/student_id_parser

module.exports = studentIDSchema =
  type: 'object'
  additionalProperties: false
  properties:
    login: type: 'string'
    tid: type: ['integer', 'null']

