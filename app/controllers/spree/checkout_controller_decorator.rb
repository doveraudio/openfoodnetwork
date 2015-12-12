Spree::CheckoutController.class_eval do

  include CheckoutHelper

  def edit
    flash.keep
    redirect_to main_app.checkout_path
  end

  private

  def before_payment
    current_order.payments.destroy_all if request.put?
  end

  # Adapted from spree_last_address gem: https://github.com/TylerRick/spree_last_address
  # Originally, we used a forked version of this gem, but encountered strange errors where
  # it worked in dev but only intermittently in staging/prod.
  def before_address
    associate_user

    last_used_bill_address, last_used_ship_address = find_last_used_addresses(@order.email)
    preferred_bill_address, preferred_ship_address = spree_current_user.bill_address, spree_current_user.ship_address if spree_current_user.respond_to?(:bill_address) && spree_current_user.respond_to?(:ship_address)

    @order.bill_address ||= preferred_bill_address || last_used_bill_address || Spree::Address.default
    @order.ship_address ||= preferred_ship_address || last_used_ship_address || nil
  end

  def after_complete
    reset_order
  end

  def find_last_used_addresses(email)
    past = Spree::Order.order("id desc").where(:email => email).where("state != 'cart'").limit(8)
    if order = past.detect(&:bill_address)
      bill_address = order.bill_address.clone if order.bill_address
      ship_address = order.ship_address.clone if order.ship_address and order.shipping_methods.map(&:require_ship_address).any?
    end

    [bill_address, ship_address]
  end
end
