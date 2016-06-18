class Api::Admin::ForPos::OrderSerializer < ActiveModel::Serializer
  include CheckoutHelper

  attributes :id, :number, :full_name, :email, :phone, :completed_at, :display_total
  attributes :subtotal, :admin_and_handling

  def subtotal
    display_checkout_subtotal(object).to_s
  end

  def admin_and_handling
    display_checkout_admin_and_handling_adjustments_total_for(object).to_s
  end

  def display_total
    object.display_total.to_s
  end

  def full_name
    object.billing_address.nil? ? "" : ( object.billing_address.full_name || "" )
  end

  def email
    object.email || ""
  end

  def phone
    object.billing_address.nil? ? "a" : ( object.billing_address.phone || "" )
  end

  def completed_at
    object.completed_at.blank? ? "" : object.completed_at.strftime("%F %T")
  end
end
