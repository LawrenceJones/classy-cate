_ = require 'underscore'
userSeeds = require 'test/seeds/users'
User = (require 'app/models').User

lawrenceJson = (new User.model(userSeeds.lawrence())).api()

token = 'eyJ0eXAiOiJKV1QiLCJhbGciO'
withToken = ->
  _.extend new Object(lawrenceJson), _meta: token: token

withoutToken = ->
  wot = withToken()
  wot._meta.token = null
  wot

module.exports = UserModel =

  name: 'User'
  labels:
    link:     'resource URI'
    token:    'generated auth token'
    email:    'user email'
    fname:    'first name'
    lname:    'last name'
    pic:      'profile picture'
    content:  'stringified profile content'
    tags:     'user tags'

  auth:
    req: ->
      email: lawrenceJson.email
      password: 'password'
    res: withToken

  get:
    res: withoutToken

  tag:

    req: ->
      tag: 'new-tag'

    res: ->
      user = withoutToken()
      user.profile.tags.push 'new-tag'
      user

  deleteTag:

    req: ->
      tag: lawrenceJson.profile.tags[0]

    res: ->
      user = withoutToken()
      user.profile.tags.shift()
      user
