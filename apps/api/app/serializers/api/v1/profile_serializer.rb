class Api::V1::ProfileSerializer < Api::V1::BaseSerializer
  attributes :id, :autotopup_gateways, :credentials
  has_many :customer_orders, key: :orders, serializer: Api::V1::CustomerOrderSerializer

  def attributes(*args)
    hash = super
    customer = object.customer

    if customer
      hash[:first_name] = customer.first_name if customer.first_name
      hash[:last_name] = customer.last_name if customer.last_name
      hash[:email] = customer.email if customer.email
    end

    hash
  end

  def first_name
    object.customer.first_name
  end

  def last_name
    object.customer.last_name
  end

  def email
    object.customer.email
  end

  def autotopup_gateways
    object.payment_gateway_customers.map(&:gateway_type)
  end

  def credentials
    object.credential_assignments
      .where(aasm_state: "assigned").map { |obj| Api::V1::CredentialAssignmentSerializer.new(obj) }
  end
end
