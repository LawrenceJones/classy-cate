lawrence = students.lawrence
authResponse =
  token: 'TOKEN', user: lawrence()

describe 'Auth Factory', ->

  $window = $httpBackend = Auth = null
  beforeEach module 'grepdoc'
  beforeEach module 'templates'

  beforeEach inject ($injector) ->
    Auth = $injector.get 'Auth'
    $httpBackend = $injector.get '$httpBackend'
    $httpBackend.whenPOST('/authenticate').respond authResponse
    $httpBackend.whenGET('/authenticate').respond authResponse
    $httpBackend.whenGET(/^\/(partials|api)/).respond 200

    $window = $injector.get '$window'
    $window.localStorage.token = undefined # clear


  describe 'on login', ->

    req = null

    beforeEach ->
      $httpBackend.expectPOST '/authenticate'
      req = Auth.login lawrence().login, 'password'
      return

    it 'should set Auth.user', (done) ->
      req.then (data) ->
        data.user.should.eql lawrence()
        data.token.should.eql 'TOKEN'
        do done
      $httpBackend.flush()
      
    it 'should set $window.token on login'


