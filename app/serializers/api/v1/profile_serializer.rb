class Api::V1::ProfileSerializer < Api::V1::BaseSerializer
  attributes :id, :banned, :autotopup_gateways, :credentials, :first_name, :last_name, :email
  has_many :customer_orders, key: :orders, serializer: Api::V1::CustomerOrderSerializer

  def first_name
    object&.customer&.first_name
  end

  def last_name
    object&.customer&.last_name
  end

  def email
    object&.customer&.email
  end

  def autotopup_gateways
    object.payment_gateway_customers.map(&:gateway_type)
  end

  def credentials
    object.active_credentials.map { |obj| Api::V1::CredentialAssignmentSerializer.new(obj) }
  end
end
