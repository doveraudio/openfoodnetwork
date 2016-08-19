angular.module("admin.pos").controller "PayController", ($scope, $http, CurrentOrder) ->
  $scope.amountToPay = 0

  $scope.$watch 'currentOrder.outstanding_balance', (newValue, oldValue) ->
    $scope.amountToPay = CurrentOrder.order.outstanding_balance

  $scope.$watch 'amountToPay', (newValue, oldValue) ->
    $scope.amountTendered = $scope.amountToPay

  $scope.$watch 'amountTendered', (newValue, oldValue) ->
    $scope.changeOwed = Math.round(100*($scope.amountTendered - $scope.amountToPay))/100

  $scope.createPayment = (paymentMethodID) ->
    order_id = CurrentOrder.order.id
    params = { payment: { amount: $scope.amountToPay, payment_method_id: paymentMethodID } }
    $http.post("/admin/orders/#{order_id}/payments", params).success (data, status) =>

      angular.noop()
    .error (response, status) =>
      @create_errors = response.errors
