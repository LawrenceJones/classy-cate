grepdoc = angular.module 'grepdoc'

# Filter for use on ng-repeat.
# Use as:
#   ng-repeat="array | column <column number>:<total columns>"
grepdoc.filter 'column', ->
  (arr, col, numCols) ->
    perCol = arr.length / numCols
    first  = Math.round(perCol*col)
    last   = Math.round(perCol*(col+1)-1)
    arr[first..last]

# Sorts an array numerically ascending
grepdoc.filter 'numericalSort', ->
  (arr) -> arr.sort()

# Reverses an array
grepdoc.filter 'reverse', ->
  (arr) -> arr.reverse()

