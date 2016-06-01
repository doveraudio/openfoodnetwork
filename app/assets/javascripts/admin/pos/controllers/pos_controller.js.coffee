angular.module("admin.pos").controller "POSCtrl", ($scope, addresses, customers, Orders, LineItems, Products, Variants) ->
  $scope.customers = customers
  $scope.orders = Orders.all
  $scope.variants = Variants.all
  $scope.currentOrderID = 0

  LineItems.linkToOrders(Orders.byID)
  LineItems.linkToVariants(Variants.byID)
  Variants.linkToProducts(Products.byID)

  $scope.$watch 'currentOrderID', (newVal, oldVal) ->
    $scope.currentOrder = Orders.byID[newVal]

  $scope.addLineItem = (variant) ->
    LineItems.add($scope.currentOrder, variant)

  $scope.removeLineItem = (lineItem) ->
    LineItems.remove(lineItem)
