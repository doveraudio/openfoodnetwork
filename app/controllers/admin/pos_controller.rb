class Admin::PosController < Spree::Admin::BaseController
  layout 'admin/bare_foundation'

  def show
    @shop = Enterprise.find(119)
    @order_cycle = OrderCycle.with_distributor(@shop).order('orders_close_at ASC').last


    @addresses = Spree::Address.preload(:state, :country).joins(shipments: :order).where(spree_orders: { distributor_id: @shop.id})
    @customers = Customer.where(enterprise_id: @shop.id)
    @orders = Spree::Order.complete.where(distributor_id: @shop.id, order_cycle_id: @order_cycle.id)
    @line_items = Spree::LineItem.where(order_id: @orders)
    @variants = Spree::Variant.visible_for(@shop).not_deleted
    @products = Spree::Product.joins(:variants).where(spree_variants: { id: @variants})
  end

  private

  def model_class
    # Slightly hacky way of getting correct authorisation for actions
    :pos
  end
end
