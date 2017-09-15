class Api::V2::OrderSerializer < ActiveModel::Serializer
  attributes :id, :status, :total, :completed_at, :gateway, :customer_id

  has_many :order_items, serializer: Api::V2::OrderItemSerializer
end
