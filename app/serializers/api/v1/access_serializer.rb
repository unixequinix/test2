module Api
  module V1
    class AccessSerializer < ActiveModel::Serializer
      attributes :id, :name, :mode, :memory_length
      attribute :memory_position, key: :position
    end
  end
end
