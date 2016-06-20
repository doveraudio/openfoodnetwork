angular.module("admin.pos").factory "CurrentOrder", ($http, $timeout, $filter, LineItems) ->
  new class CurrentOrder
    order: {}
    update_running: false
    update_enqueued: false

    removeLineItem: (lineItem) ->
      lineItem.quantity = 0
      @clearTotals()
      @triggerChange()

    addVariant: (variant) =>
      lineItem = @findByVariantID(variant.id)
      if lineItem?
        lineItem.display_amount_with_adjustments = null
        lineItem.order
        lineItem.quantity += 1
      else
        @order.lineItems.push { order: @order, variant: variant, quantity: 1 }
      @clearTotals()
      @triggerChange()

    triggerChange: ->
      if !@update_running
        @scheduleUpdate()
      else
        @update_enqueued = true

    scheduleUpdate: (timeout=1000) =>
      if @promise
        $timeout.cancel(@promise)
      @promise = $timeout @update, timeout

    update: =>
      update_running = true

      $http.post("/admin/orders/#{@order.number}/populate", @data()).success (data, status) =>
        @updateLineItem(attrs) for attrs in data.line_items
        @remove(id) for id in data.deleted
        angular.extend(@order, data.order)

        @update_running = false

        @popQueue() if @update_enqueued

      .error (response, status)=>
        @scheduleRetry(data, status)
        @update_running = false

    scheduleRetry: (data, status) =>
      console.log "Error updating cart: #{status}. Retrying in 3 seconds..."
      $timeout =>
        console.log "Retrying cart update"
        @scheduleUpdate(0)
      , 3000

    popQueue: =>
      @update_enqueued = false
      @scheduleUpdate(0)

    data: =>
      variants = {}
      for li in @line_items_present()
        variants[li.variant.id] =
          quantity: li.quantity
      {variants: variants}

    line_items_present: =>
      @order.lineItems.filter (li) ->
        li.quantity > 0

    updateLineItem: (attrs) =>
      lineItem = @findByVariantID(attrs.variant.id)
      unless lineItem.quantity == 0 # unless this line item has subsequently been deleted
        delete attrs.variant
        delete attrs.order
        angular.extend(lineItem, attrs)
        unless LineItems.byID[lineItem.id]
          LineItems.all.push lineItem
          LineItems.byID[attrs.id] = lineItem

    remove: (id) ->
      lineItem = @findByVariantID(id)
      if lineItem.quantity == 0 # if this line item hasn't been subsequently added again
        index = @order.lineItems.indexOf(lineItem)
        @order.lineItems.splice(index, 1) if index > -1
        index = LineItems.all.indexOf(lineItem)
        LineItems.all.splice(index, 1) if index > -1
        LineItems.byID[lineItem.id] = lineItem

    findByVariantID: (variantID) ->
      $filter('filter')(@order.lineItems, (lineItem) -> lineItem.variant.id == variantID)[0]

    clearTotals: ->
      @order.subtotal = null
      @order.admin_and_handling = null
      @order.display_total = null

    # saved: =>
    #   @dirty = false
    #   $(window).unbind "beforeunload"
    #
    # unsaved: =>
    #   @dirty = true
    #   $(window).bind "beforeunload", ->
    #     t 'order_not_saved_yet'
