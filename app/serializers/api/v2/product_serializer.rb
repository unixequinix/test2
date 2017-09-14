class Api::V2::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :description, :is_alcohol, :vat, :price, :position
end
