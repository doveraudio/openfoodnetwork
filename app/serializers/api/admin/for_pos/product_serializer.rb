class Api::Admin::ForPos::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :variant_unit, :variant_unit_scale, :variant_unit_name

  has_one :supplier, serializer: Api::Admin::IdSerializer
  has_one :primary_taxon, serializer: Api::Admin::IdSerializer
  has_many :images, serializer: Api::ImageSerializer
end
