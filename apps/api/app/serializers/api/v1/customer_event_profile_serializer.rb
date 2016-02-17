class Api::V1::CustomerEventProfileSerializer < Api::V1::BaseSerializer
  attributes :id
  has_many :credential_assignments, root: :credentials,
                                    serializer: Api::V1::CredentialAssignmentSerializer
  has_many :customer_orders, root: :orders, serializer: Api::V1::CustomerOrderSerializer

  def attributes(*args)
    hash = super
    customer = object.customer

    if customer
      hash[:name] = customer.name if customer.name
      hash[:surname] = customer.surname if customer.surname
      hash[:email] = customer.email if customer.email
    end

    hash
  end

  def name
    object.customer.name
  end

  def surname
    object.customer.surname
  end

  def email
    object.customer.email
  end
end
