classy = angular.module 'classy'

# <i mime-type-icon="pdf"></i>
classy.directive 'mimeTypeIcon', ->

  # Returns a fontawesome class name for icon based on given exercise type
  getIcon = (type) ->
    switch type
      when "pdf" then return "fa-file-pdf-o"
      when "url" then return "fa-external-link"
      when "ESSAY" then return "fa-align-left"
      when "TUT" then return "fa-institution"
      when "CW" then return "fa-folder-o"
      when "LAB" then return "fa-code"
      else return "fa-pencil-square-o"

  restrict: 'A'
  replace: true
  template: "<i class=\"fa\"></i>"
  link: ($scope, $i, attr) ->
    $i.addClass getIcon $scope.$eval(attr.mimeTypeIcon)

