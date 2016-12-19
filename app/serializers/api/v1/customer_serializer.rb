class Api::V1::CustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :credentials, :first_name, :last_name, :email, :orders

  def orders
    object.completed_order_items.map { |item| Api::V1::OrderItemSerializer.new(item) }
  end

  def credentials
    object.active_credentials.map { |obj| Api::V1::CredentialAssignmentSerializer.new(obj) }
  end
end
