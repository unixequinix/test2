class Api::V1::OrderItemSerializer < Api::V1::BaseSerializer
  attributes :online_order_counter, :catalog_item_id, :amount
end
