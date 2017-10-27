module Api::V2
  class ProductSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :is_alcohol, :vat, :price, :position
  end
end
