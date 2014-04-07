classy = angular.module 'classy'

classy.directive 'buttonsRadio', ($compile) ->
  restrict: 'CA'
  compile: (tElem, tAttr) ->
    model = tAttr.model
    eqModel = model
    if tAttr.activeValue? then eqModel = "#{tAttr.activeValue}(#{model})"
    tElem.append $ """
    <button type="button" class="btn btn-default"
            ng-class="{active: option == #{eqModel}}"
            ng-repeat="option in #{tAttr.options}"
            ng-click="#{model} = option"> {{ option.label }}
    </button>"""

classy.directive 'buttonDropdown', ($compile) ->
  restrict: 'CA'
  compile: (tElem, tAttr) ->
    model = tAttr.model
    tElem.append $ """
    <button type="button" class="btn btn-default dropdown-toggle"
            data-toggle="dropdown">
            {{ #{model}.label || '#{tAttr.placeholder}' || 'Select...' }}
            <span class="caret"></span>
    </button>
    <ul class="dropdown-menu">
      <li ng-repeat="option in #{tAttr.options}">
        <a ng-click="#{model} = option">
          {{ option.label }}
        </a>
      </li>
    </ul>"""
