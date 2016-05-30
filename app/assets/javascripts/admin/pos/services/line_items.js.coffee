angular.module("admin.pos").factory "LineItems", ($resource, lineItems) ->
  new class LineItems
    all: []
    byID: {}

    constructor: ->
      for lineItem in lineItems
        @all.push lineItem
        @byID[lineItem.id] = lineItem

    linkToOrders: (ordersByID) ->
      for lineItem in @all
        lineItem.order = ordersByID[lineItem.order.id]
        lineItem.order.lineItems ||= []
        lineItem.order.lineItems.push lineItem

    linkToVariants: (variantsByID) ->
      for lineItem in @all
        lineItem.variant = variantsByID[lineItem.variant.id]
