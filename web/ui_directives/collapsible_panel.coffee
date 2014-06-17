grepdoc = angular.module 'grepdoc'

grepdoc.directive 'collapsiblePanel', ->
  restrict: 'A'

  link: ($scope, $panel, attr) ->
    defaultCollapse = attr.collapseDefault?

    $trigger = $("<i>")
      .addClass("fa")
      .addClass(if defaultCollapse then 'fa-chevron-down' else 'fa-chevron-up')
      .addClass("panel-collapse-trigger")
      .attr("data-toggle", "collapse")
      .attr("data-target", "##{attr.id} .panel-body")
      .click (->
        $(this)
          .toggleClass 'fa-chevron-down'
          .toggleClass 'fa-chevron-up')

    $panel.find("h3.panel-title").append($trigger)
    $panel.find(".panel-body")
      .addClass("collapse")
      .addClass("in" if not defaultCollapse ? "")

