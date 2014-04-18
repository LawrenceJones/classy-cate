classy = angular.module 'classy'

# Implemented as jQuery for performance, as ng-repeat cause far
# too many expensive double binds.
classy.directive 'paperBtns', ($compile, $state) ->
  restrict: 'A'
  template: """
    <div class="btn-group paper-btns">
    </div>"""
  scope: exam: '&paperBtns', placeholder:  '@'
  link: ($scope, $elem, attr) ->
    cut = parseInt (attr.cut || '3'), 10
    papers = $scope.exam().papers
    $btns = $elem.find '.paper-btns'
    papers[0..cut].map (p) ->
      $btns.append $ """
        <a class="btn btn-default" target="_blank"
           href="#{p.url}">#{p.year}-#{p.year + 1}</a>"""
    if papers.length > cut + 1
      $btnGroup = $ """
        <div class="btn-group">
          <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
            #{$scope.placeholder || 'More'}
            <span class="caret"></span>
          </button>
        </div>"""
      $ul = $ """<ul class="dropdown-menu"></ul>"""
      papers[(cut + 1)..].map (p) ->
        $ul.append $ """
          <li>
            <a target="_blank" href="#{p.url}">
              #{p.year}-#{p.year + 1}
            </a>
          </li>"""
      $btnGroup.append $ul
      $btnGroup.appendTo $btns




