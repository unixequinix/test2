module Api
  module V1
    class CustomerSerializer < ActiveModel::Serializer
      attributes :id, :first_name, :last_name, :email, :orders, :credentials

      def orders
        ords = OrderItem.where(order: object.orders.where(status: %w[completed cancelled]))
        ords.map { |item| Api::V1::OrderItemSerializer.new(item) }
      end

      def credentials
        object.active_credentials.map { |credential| Api::V1::CredentialSerializer.new(credential) }
      end
    end
  end
end
