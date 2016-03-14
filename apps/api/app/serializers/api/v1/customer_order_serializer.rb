class Api::V1::CustomerOrderSerializer < Api::V1::BaseSerializer
  attributes :online_order_counter, :product, :amount

  def online_order_counter
    object.online_order && object.online_order.counter
  end

  def product
    object.catalog_item_id
  end
end
