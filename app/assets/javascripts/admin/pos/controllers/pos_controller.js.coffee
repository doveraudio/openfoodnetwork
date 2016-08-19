angular.module("admin.pos").controller "POSCtrl", ($scope, addresses, customers, CurrentOrder, Orders, LineItems, Products, Variants) ->
  $scope.customers = customers
  $scope.orders = Orders.all
  $scope.variants = Variants.all
  $scope.currentOrderID = 0
  $scope.config = { view: 'products' }

  LineItems.linkToOrders(Orders.byID)
  LineItems.linkToVariants(Variants.byID)
  Variants.linkToProducts(Products.byID)

  $scope.$watch 'currentOrderID', (newVal, oldVal) ->
    CurrentOrder.order = Orders.byID[newVal]
    $scope.currentOrder = CurrentOrder.order
    $scope.config.view = 'products'

  $scope.addLineItem = (variant) ->
    CurrentOrder.addVariant(variant)

  $scope.removeLineItem = (lineItem) ->
    CurrentOrder.removeLineItem(lineItem)
