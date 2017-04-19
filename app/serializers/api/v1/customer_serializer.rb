class Api::V1::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :orders, :credentials

  def orders
    ords = OrderItem.where(order: object.orders.where(status: %w[completed cancelled]))
    ords.map { |item| Api::V1::OrderItemSerializer.new(item) }
  end

  def credentials
    object.active_credentials.map { |obj| Api::V1::CredentialSerializer.new(obj) }
  end
end
