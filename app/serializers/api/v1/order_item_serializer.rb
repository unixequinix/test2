class Api::V1::OrderItemSerializer < Api::V1::BaseSerializer
  attributes :id, :catalog_item_id, :amount

  def id
    object.counter
  end
end
