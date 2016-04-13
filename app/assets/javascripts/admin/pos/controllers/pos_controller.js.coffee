angular.module("admin.pos").controller "POSCtrl", ($scope, addresses, customers, orders, line_items, products, variants) ->
  $scope.lala = "lalala"
  $scope.customers = customers
  $scope.orders = orders
