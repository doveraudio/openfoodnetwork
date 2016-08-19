Spree::Admin::PaymentsController.class_eval do
  # When a user fires an event, take them back to where they came from
  # Responder: http://guides.spreecommerce.com/developer/logic.html#overriding-controller-action-responses

  # For some strange reason, adding PaymentsController.class_eval will cause gems/spree/app/controllers/spree/admin/payments_controller.rb:37 to error:
  #   payments_url not defined.
  # This could be fixed by replacing line 37 with:
  #   respond_with(@payment, location: admin_order_payments_url) { |format| format.html { redirect_to admin_order_payments_path(@order) } }
  respond_override :fire => { :html => { :success => lambda {
    redirect_to request.referer  # Keeps any filter and sort prefs
  } } }

  respond_override create: { json: { success: lambda {
    if request.referrer == main_app.admin_pos_url
      order = Api::Admin::ForPos::OrderSerializer.new(@order.reload).serializable_hash
      render json: { order: order }
    else
      render_as_json @payment.reload
    end
  } } }

  def update
  if @line_item.update_attributes(params[:line_item])
    respond_with(@line_item) do |format|
      format.html { render :partial => 'spree/admin/orders/form', :locals => { :order => @order.reload } }
    end
  else
    respond_with(@line_item) do |format|
      format.html { render :partial => 'spree/admin/orders/form', :locals => { :order => @order.reload } }
    end
  end
end

  append_before_filter :filter_payment_methods

  # Only show payments for the order's distributor
  def filter_payment_methods
    @payment_methods = @payment_methods.select{ |pm| pm.has_distributor? @order.distributor}
    @payment_method ||= @payment_methods.first
  end

end
