class Api::Admin::ForPos::VariantSerializer < ActiveModel::Serializer
  attributes :id, :options_text, :unit_value, :unit_description, :unit_to_display, :display_as, :display_name, :name_to_display
  attributes :price

  has_one :product, serializer: Api::Admin::IdSerializer
end
