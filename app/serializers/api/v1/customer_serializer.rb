class Api::V1::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :credentials, :first_name, :last_name, :email, :orders

  def orders
    ords = OrderItem.where(order: object.orders.where(status: ['completed', 'cancelled']))
    ords.map { |item| Api::V1::OrderItemSerializer.new(item) }
  end

  def credentials
    object.active_credentials.map { |obj| Api::V1::CredentialAssignmentSerializer.new(obj) }
  end
end
