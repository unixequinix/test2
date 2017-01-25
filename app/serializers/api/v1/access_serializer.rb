class Api::V1::AccessSerializer < ActiveModel::Serializer
  attributes :id, :name, :mode, :memory_length
  attribute :memory_position, key: :position
end
