angular.module("admin.pos").factory "Orders", (orders) ->
  new class Orders
    all: []
    byID: {}

    constructor: ->
      for order in orders
        @all.push order
        @byID[order.id] = order for order in orders
