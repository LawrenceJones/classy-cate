# Global routing for site.
module.exports = (app) ->

  # Routes authorization methods
  (require './auth')(app)

  # Routes CATe api
  (require './api')(app)

  # Uploading facilities.
  (require './uploads')(app)

  # Routes any utilities
  (require './utilities')(app)
