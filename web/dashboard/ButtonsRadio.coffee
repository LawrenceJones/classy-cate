classy = angular.module 'classy'

classy.directive 'buttonsRadio', ($compile) ->
  restrict: 'CA'
  compile: (tElem, tAttr) ->
    model = tAttr.model
    eqModel = model
    if tAttr.activeValue? then eqModel = "#{tAttr.activeValue}(#{model})"
    tElem.append $ """
    <button type="button" class="btn btn-default"
            ng-class="{active: option.value == #{eqModel}}"
            ng-repeat="option in #{tAttr.options}"
            ng-click="#{model} = option.value"> {{ option.label }}
    </button>"""
