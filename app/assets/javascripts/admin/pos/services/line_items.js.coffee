angular.module("admin.pos").factory "LineItems", ($resource, lineItems, Orders, Variants) ->
  LineItemResource = $resource '/admin/orders/:order_id/line_items/:id/:action.json', {order_id: '@order_id'},
    'add':
      method: 'POST'
    'remove':
      method: 'DELETE'
  new class LineItems
    all: []
    byID: {}

    constructor: ->
      for lineItem in lineItems
        @all.push lineItem
        @byID[lineItem.id] = lineItem

    linkToOrders: ->
      for lineItem in @all
        @linkToOrder(lineItem)

    linkToOrder: (lineItem) ->
      lineItem.order = Orders.byID[lineItem.order.id]
      lineItem.order.lineItems ||= []
      lineItem.order.lineItems.push lineItem

    linkToVariants: ->
      for lineItem in @all
        @linkToVariant(lineItem)

    linkToVariant: (lineItem) ->
        lineItem.variant = Variants.byID[lineItem.variant.id]

    add: (order, variant) ->
      params =
        order_id: order.number
        variant_id: variant.id
        quantity: 2
      LineItemResource.add params, (lineItem) =>
        @all.push lineItem
        @byID[lineItem.id] = lineItem
        @linkToOrder(lineItem)
        @linkToVariant(lineItem)

    remove: (lineItem) ->
      params =
        id: lineItem.id
        order_id: lineItem.order.number
      LineItemResource.remove params, =>
        lineItems = lineItem.order.lineItems
        index = lineItems.indexOf(lineItem)
        lineItems.splice(index, 1) if index > -1
        index = @all.indexOf(lineItem)
        @all.splice(index, 1) if index > -1
        @byID[lineItem.id] = lineItem
