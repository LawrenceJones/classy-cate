classy = angular.module 'classy'

# A class with useful formatting methods for use throughout.
classy.service 'FormattingService', ->

  termsArrayToString: (terms) ->
    terms.join ", "

  courseArrayToString: (courses) ->
    courses.join "  "
