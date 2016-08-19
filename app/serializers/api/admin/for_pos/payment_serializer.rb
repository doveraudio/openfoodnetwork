class Api::Admin::ForPos::PaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :display_amount, :state

  has_one :payment_method, serializer: Api::Admin::IdNameSerializer

  def display_amount
    object.display_amount.to_s
  end
end
