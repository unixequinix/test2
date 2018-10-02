module Api::V2
  class OrderItemSerializer < ActiveModel::Serializer
    attributes :id, :amount, :redeemed, :counter, :catalog_item_id, :catalog_item_type, :credits

    def catalog_item_type
      object.catalog_item.class.to_s
    end
  end
end
