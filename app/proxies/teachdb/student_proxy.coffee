HTTPIndexedProxy       = require 'app/proxies/http_indexed_proxy'
StudentParser   = require 'app/parsers/teachdb/student_parser'
StudentIDParser = require 'app/parsers/teachdb/student_id_parser'
# This is the proxy object that will allow parsing of a student from the teachdb
# database. Newed with StudentIDParser as an Indexer, the proxy can resolve any
# college logins to tids without requiring that information from the caller.
module.exports = StudentProxy =
  new HTTPIndexedProxy StudentParser, StudentIDParser


