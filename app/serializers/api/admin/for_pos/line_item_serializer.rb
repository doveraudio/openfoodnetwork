class Api::Admin::ForPos::LineItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :single_display_amount_with_adjustments, :display_amount_with_adjustments
  attributes :final_weight_volume, :options_text

  has_one :variant, serializer: Api::Admin::IdSerializer
  has_one :order, serializer: Api::Admin::IdSerializer

  def final_weight_volume
    object.final_weight_volume.to_f
  end

  def single_display_amount_with_adjustments
    object.single_display_amount_with_adjustments.to_s
  end

  def display_amount_with_adjustments
    object.display_amount_with_adjustments.to_s
  end
end
