angular.module("admin.pos").controller "PayController", ($scope, $http, CurrentOrder) ->
  $scope.inProgress = false
  $scope.payment =
    amount: null
    payment_method_id: null

  $scope.$watch 'currentOrder.outstanding_balance', (newValue, oldValue) ->
    $scope.payment.amount = CurrentOrder.order?.outstanding_balance
    $scope.payment.payment_method_id = null

  $scope.$watch 'payment.amount', (newValue, oldValue) ->
    $scope.amountTendered = $scope.payment.amount

  $scope.$watch 'amountTendered', (newValue, oldValue) ->
    $scope.changeOwed = Math.round(100*($scope.amountTendered - $scope.payment.amount))/100

  $scope.createPayment = ->
    $scope.inProgress = true
    order_number = CurrentOrder.order.number
    params = { payment: $scope.payment }
    $http.post("/admin/orders/#{order_number}/payments.json", params).success (data, status) =>
      angular.extend(CurrentOrder.order, data.order)
      $('#pay-modal').foundation('reveal', 'close');
      $scope.inProgress = false
    .error (response, status) =>
      alert(response.errors[0])
      $scope.inProgress = false
