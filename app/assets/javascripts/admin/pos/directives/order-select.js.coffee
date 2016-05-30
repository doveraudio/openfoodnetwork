angular.module("admin.pos").directive "orderSelect", ($sanitize, $timeout) ->
  require: 'ngModel'
  restrict: 'C'
  scope:
    data: "="
    minSearch: "@?"
  link: (scope, element, attrs, ngModel) ->
    $timeout ->
      item.name = $sanitize(item.name) for item in scope.data
      element.select2
        width: "100%"
        placeholder: "Select an order..."
        minimumResultsForSearch: scope.minSearch || 0
        data: { results: scope.data, text: 'full_name' }
        formatSelection: (item) ->
          "<b>#{item.full_name}</b> (#{item.completed_at})"
        formatResult: (item) ->
          "<b>#{item.full_name}</b> (#{item.completed_at})"

      element.on 'select2-selecting', (e) ->
        ngModel.$setViewValue(e.val)

    attrs.$observe 'disabled', (value) ->
      element.select2('enable', !value)

    ngModel.$formatters.push (value) ->
      element.select2('val', value)
      value
