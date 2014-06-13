StudentProxy = require './student_proxy'

module.exports = StudentRoutes =

  # GET /api/student/:login
  getOne:
    url: '/api/student/:login'
    get: (req, res) ->

      # Validate login
      login = req.params.login
      if !/^\w+$/.test login
        return res.send 400, 'Valid login required'

      # Find student teachdb ID
      StudentProxy.scrapeStudent

    
