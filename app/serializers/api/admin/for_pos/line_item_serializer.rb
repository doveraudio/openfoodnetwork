class Api::Admin::ForPos::LineItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price, :final_weight_volume, :options_text

  has_one :variant, serializer: Api::Admin::IdSerializer
  has_one :order, serializer: Api::Admin::IdSerializer

  def final_weight_volume
    object.final_weight_volume.to_f
  end
end
