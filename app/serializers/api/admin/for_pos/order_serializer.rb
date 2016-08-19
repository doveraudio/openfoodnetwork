class Api::Admin::ForPos::OrderSerializer < ActiveModel::Serializer
  include CheckoutHelper

  attributes :id, :number, :full_name, :email, :phone, :completed_at, :display_total
  attributes :display_subtotal, :display_admin_and_handling
  attributes :payment_total, :display_payment_total, :outstanding_balance, :display_outstanding_balance

  has_many :payments, serializer: Api::Admin::ForPos::PaymentSerializer

  def display_subtotal
    display_checkout_subtotal(object).to_s
  end

  def display_admin_and_handling
    display_checkout_admin_and_handling_adjustments_total_for(object).to_s
  end

  def display_total
    object.display_total.to_s
  end

  def display_outstanding_balance
    object.display_outstanding_balance.to_s
  end

  def outstanding_balance
    object.outstanding_balance.to_f
  end

  def display_payment_total
    object.display_payment_total.to_s
  end

  def payment_total
    object.payment_total.to_f
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
