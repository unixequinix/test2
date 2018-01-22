module Api
  module V1
    class OrderItemSerializer < ActiveModel::Serializer
      attributes :catalog_item_id, :catalog_item_type, :amount, :status, :redeemed
      attribute :counter, key: :id

      def catalog_item_type
        object.catalog_item.class.to_s if object.catalog_item
      end

      def status
        object.order.status
      end
    end
  end
end
