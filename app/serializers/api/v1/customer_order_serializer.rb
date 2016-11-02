class Api::V1::CustomerOrderSerializer < Api::V1::BaseSerializer
  attributes :online_order_counter, :catalogable_id, :catalogable_type, :amount

  def online_order_counter
    object.counter
  end

  def catalogable_id
    object.catalog_item.catalogable_id
  end

  def catalogable_type
    object.catalog_item.catalogable_type.downcase
  end
end
