class Admin::PosController < Spree::Admin::BaseController
  layout 'admin/bare_foundation'

  before_filter :ensure_shop_and_oc_selected, only: :data

  def show
    @shops = Enterprise.managed_by(spree_current_user)
  end

  def data
    @addresses = Spree::Address.preload(:state, :country).joins(shipments: :order).where(spree_orders: { distributor_id: @shop.id})
    @customers = Customer.where(enterprise_id: @shop.id)
    @orders = Spree::Order.preload(payments: :payment_method).complete.where(distributor_id: @shop.id, order_cycle_id: @order_cycle.id)
    @line_items = Spree::LineItem.preload(:order, :variant).where(order_id: @orders)
    @variants = Spree::Variant.where(id: @line_items.pluck(:variant_id)).preload(:product) | @order_cycle.variants_distributed_by(@shop).preload(:product)
    @products = Spree::Product.preload(:supplier, :taxons, master: :images).joins(:variants).where(spree_variants: { id: @variants})
    @payment_methods = @shop.payment_methods.where(type: "Spree::PaymentMethod::Check")
  end

  private

  def ensure_shop_and_oc_selected
    @shop = Enterprise.find_by_id(params[:shop_id])
    @order_cycle = OrderCycle.find_by_id(params[:order_cycle_id])
    render_scope unless @shop && @order_cycle
    authorize! :
  end

  def model_class
    # Slightly hacky way of getting correct authorisation for actions
    :pos
  end
end
