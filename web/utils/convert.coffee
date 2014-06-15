classy = angular.module 'classy'

# Service for converting various datas
# Example use: `Convert.termToPeriod 2`
classy.service 'Convert', ->
  
  periodToTerm: (period) ->
    Math.ceil period / 2

  termToPeriod: (term) ->
    2 * term - 1

  termToName: (term) ->
    return if term not in [1..3]
    [ "Autumn", "Spring", "Summer" ][term-1]

