class Admin::PosController < Spree::Admin::BaseController
  layout 'admin/bare_foundation'

  def show
    @distributor = Enterprise.find(119)
    @order_cycle = OrderCycle.with_distributor(@distributor).order('orders_close_at ASC').last


    @addresses = Spree::Address.joins(shipments: :order).where(spree_orders: { distributor_id: @distributor.id})
    @customers = Customer.where(enterprise_id: @distributor.id)
    @orders = Spree::Order.complete.where(distributor_id: @distributor.id, order_cycle_id: @order_cycle.id)
    @line_items = Spree::LineItem.where(order_id: @orders)
    @variants = Spree::Variant.visible_for(@distributor)
    @products = Spree::Product.joins(:variants).where(spree_variants: { id: @variants})
  end

  private

  def model_class
    # Slightly hacky way of getting correct authorisation for actions
    :pos
  end
end
