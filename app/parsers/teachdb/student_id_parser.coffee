TIDParser = require './tid_parser'

# Parses student teachdb table ID
# Accepts data from ~/db/viewtab?table=Student&arg1=<LOGIN>
module.exports = class StudentIDParser extends TIDParser

  # Requires a student college login
  # Eg. {login: "lmj112"}
  @url: (query) ->
    login = query.login
    if not login? then throw Error 'Missing login query parameters'
    super value: login, table: 'Student', argKey: 'arg1'

