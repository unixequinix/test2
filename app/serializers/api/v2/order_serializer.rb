module Api::V2
  class OrderSerializer < ActiveModel::Serializer
    attributes :id, :status, :total, :completed_at, :gateway, :customer_id

    has_many :order_items, serializer: OrderItemSerializer
  end
end
