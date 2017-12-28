module Api
  module V1
    class OrderItemSerializer < ActiveModel::Serializer
      attributes :catalog_item_id, :amount, :status, :redeemed
      attribute :counter, key: :id

      def status
        object.order.status
      end
    end
  end
end
