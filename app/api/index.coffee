config = require 'app/etc/config'

module.exports = Api =

  # Given a mongoose schema and a set of formatters, organised such
  # that each formatter is assigned a specific key, denoting the API
  # version for that format. An example...
  #
  #     1A: -> # formatter
  #
  # Where '1A' is the API version and the function is a formatter that
  # when run in the context of one of your mongoose instances will
  # generate a new JS object, totally bare and fresh for serialization.
  register: (schema, formats = {}) ->
    schema.methods.api = (version = config.API_VERSION, args...) ->
      try return formats[version].call @, args...
      catch err then throw new Error """
      Formatter not yet implemented for API version #{version}.
      Current repo version is #{config.API_VERSION}.
      """
      




