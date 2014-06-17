grepdoc = angular.module 'grepdoc'

# Service for formatting various types of input.
# Example use: `Format.asEnglishList myarray`
grepdoc.service 'Format', ->

  asEnglishList: (arr) ->
    return arr.join '' if (len = arr.length) <= 1
    (arr[0..len-2].join ", ") + " and " + arr[len-1]

  pluraliseIf: (str, n) ->
    str + (('s' if n isnt 1) ? '')

