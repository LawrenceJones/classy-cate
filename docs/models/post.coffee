_ = require 'underscore'
postSeeds = require 'test/seeds/posts'
labels = (require './booking').labels

PostModel =

  name: 'Post'
  labels: labels

module.exports = _.extend PostModel, postSeeds



