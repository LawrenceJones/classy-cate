classy = angular.module 'classy'

# Filter for use on ng-repeat.
# Use as:
#   ng-repeat="array | column <column number>:<total columns>"
classy.filter 'column', ->
  (arr, col, numCols) ->
    perCol = arr.length / numCols
    first  = Math.round(perCol*col)
    last   = Math.round(perCol*(col+1)-1)
    arr[first..last]

