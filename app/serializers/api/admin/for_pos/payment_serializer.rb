class Api::Admin::ForPos::PaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :state

  has_one :payment_method, serializer: Api::Admin::IdNameSerializer
end
