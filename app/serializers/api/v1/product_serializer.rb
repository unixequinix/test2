module Api
  module V1
    class ProductSerializer < ActiveModel::Serializer
      attributes :id, :name, :description, :is_alcohol
    end
  end
end
