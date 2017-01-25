class Api::V1::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :is_alcohol
end
