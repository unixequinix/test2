class Api::V1::CustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :credentials, :first_name, :last_name, :email
  has_many :order_items, key: :orders, serializer: Api::V1::OrderItemSerializer

  def credentials
    object.active_credentials.map { |obj| Api::V1::CredentialAssignmentSerializer.new(obj) }
  end
end
