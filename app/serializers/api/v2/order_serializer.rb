module Api::V2
  class OrderSerializer < ActiveModel::Serializer
    attributes :id, :customer_id, :status, :completed_at, :gateway, :money_base, :money_fee

    has_many :order_items, serializer: OrderItemSerializer
  end
end
