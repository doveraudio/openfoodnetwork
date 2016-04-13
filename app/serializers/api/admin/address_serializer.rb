class Api::Admin::AddressSerializer < ActiveModel::Serializer
  attributes :id, :firstname, :lastname, :address1, :address2, :city, :zipcode, :phone

  has_one :state, serializer: Api::Admin::IdNameSerializer
  has_one :country, serializer: Api::Admin::IdNameSerializer
end
