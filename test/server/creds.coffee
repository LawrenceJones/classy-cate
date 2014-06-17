fs = require 'fs'
CREDS_FILE = "#{process.env.HOME}/.imp"

# Format the ~/.imp file...
#
#   login
#   password
#   <opts>
#
# Where <opts> is an arbitrary list of test route preferences. To
# automate testing of the CATe parsers, sensible defaults for query
# params like 'year', 'class' and 'period' are required.
#
# Represent these options as a single line, key:value style...
#
#   year:2013
#   period:5
#   class:c2
#
# Otherwise on each test, the dev will be prompted for this info. TODO

if fs.existsSync CREDS_FILE
  [login, pass, opts...] =
    fs.readFileSync(CREDS_FILE, 'utf8').split('\n')
      .filter (s) -> !/^[\s\t\r\n]*$/.test s
  creds = user: login, pass: pass, opt: {}
  for o in opts
    [key,value] = o.split ':'
    creds.opt[key] = value
  creds.opt.login = creds.opt.user = login
else
  throw new Error 'No ~/.imp file!'

module.exports = creds
