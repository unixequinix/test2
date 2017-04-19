class Api::V2::OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :amount, :total, :redeemed, :counter
end
