TIDParser = require './tid_parser'

# Parses course teachdb table ID
# Accepts data from ~/db/viewtab?table=Course&arg1=<LOGIN>
module.exports = class StudentIDParser extends TIDParser

  # Requires a course ID
  # Eg. {cid: "202"}
  @url: (query) ->
    cid = query.cid
    if not cid? then throw Error 'Missing cid query parameter'
    super value: cid, table: 'Course', argKey: 'arg0'

