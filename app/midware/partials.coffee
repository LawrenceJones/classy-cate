# Given a views structure as below...
#
#     views/
#     ├── bookings
#     │   ├── bookings.jade
#     │   ├── bookings.list.jade
#     │   └── bookings.view.jade
#     ├── layout.jade
#
# Will attempt to render any jade files targetted by the
# http request.
#
# The middleware should be configured with these options...
#
#     views:  the actual project level views directory
#     prefix: the url prefix to map into the views folder
#
# Behaviour with { prefix: /partials, views: views } is
# that a request to / as a url will render the layout.jade
# file.
# A request to /partials/bookings will render the booking
# jade file within the /bookings folder. If a views subdir
# contains multiple views to be rendered, then the url req
# must specify filename.
#
# Simply, the following URLs will render...
#
#     GET /
#     {views}/layout.jade
#
#     GET /partials/:name
#     {views}/:name/:name.jade
#
#     GET /partials/:name/:file.jade
#     {views}/:name/:file.jade
#

fs   = require 'fs'
path = require 'path'
jade = require 'jade'

# Export a configuration function for the middleware
module.exports = (options) ->

  # Configure options
  if not options.views
    throw new Error 'Jade middleware requires a views directory'
  options[k] ?= v for k,v of {
    prefix: '/partials'
  }

  # Remove the first slash for uniformity
  options.prefix = options.prefix.replace /^\/+/, ''

  urlRex = new RegExp "^/(#{options.prefix}/([^/]+)(/([^/]+))?)?$"

  genPath = (name, file) ->
    if name and file
      path.join options.views, name, "#{file}.jade"
    else if name
      path.join options.views, name, "#{name}.jade"
    else
      path.join options.views, 'layout.jade'

  (req, res, next) ->
    if (/get/i.test req.method) and (urlRex.test req.path)
      [_,_,name,_,file] = req.path.match urlRex
      if jpath = genPath name, file
        return res.send jade.renderFile jpath
    do next
      
            

