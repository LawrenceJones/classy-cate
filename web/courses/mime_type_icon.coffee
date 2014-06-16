classy = angular.module 'classy'

# <i mime-type-icon="pdf"></i>
classy.directive 'mimeTypeIcon', ->

  # Returns a fontawesome class name for icon based on given exercise type
  getIcon = (type) ->
    ({
      PDF: 'fa-file-pdf-o'
      URL: 'fa-extenal-link'
      ESSAY: 'fa-align-left'
      TUT: 'fa-institution'
      CW: 'fa-folder-o'
      LAB: 'fa-code'
    })[type?.toUpperCase()] || 'fa-pencil-square-o'

  restrict: 'A'
  replace: true
  template: "<i class=\"fa\" data-placement=\"top\"></i>"
  link: ($scope, $i, attr) ->
    type = $scope.$eval attr.mimeTypeIcon
    $i.addClass getIcon type

    # Add and enable tooltip
    $i.attr "title", type
    $i.attr "data-toggle", "tooltip"
    $i.tooltip()

