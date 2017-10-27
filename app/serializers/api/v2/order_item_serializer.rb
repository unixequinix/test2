module Api::V2
  class OrderItemSerializer < ActiveModel::Serializer
    attributes :id, :amount, :total, :redeemed, :counter
  end
end
