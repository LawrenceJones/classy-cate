# Loads chai should, with promise support
(global.chai = require 'chai').should()
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
[global.expect, global.assert] = [chai.expect, chai.assert]

# Loads Imperial Credentials
global.creds = require 'test/server/creds'

