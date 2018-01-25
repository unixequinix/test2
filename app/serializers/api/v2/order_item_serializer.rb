module Api::V2
  class OrderItemSerializer < ActiveModel::Serializer
    attributes :id, :amount, :redeemed, :counter
  end
end
