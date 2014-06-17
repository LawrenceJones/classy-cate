console.log 'This'

describe 'Auth unit tests', ->

  [$compile, $rootScope] = [null, null]

  beforeEach -> angular.mock.module 'grepdoc'

  beforeEach ->
    inject ['$compile', '$rootScope', ($c, $r) ->
      $compile = $c
      $rootScope = $r
    ]

  it 'should run this test', ->
    return true
