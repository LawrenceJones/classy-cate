# Global routing for site.
module.exports = (app) ->

  # Routes authorization methods
  (require './auth')(app)

  # Routes CATe api
  (require './api')(app)

  # Routes for publishing documents, etc.
  (require './exams')(app)

  # Routes any utilities
  (require './utilities')(app)
