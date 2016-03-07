class Api::V1::CustomerEventProfileSerializer < Api::V1::BaseSerializer
  attributes :id
  has_many :credential_assignments, root: :credentials,
                                    serializer: Api::V1::CredentialAssignmentSerializer

  # TODO: Needs to be reviewed after we add sample data
  has_many :customer_orders, root: :orders, serializer: Api::V1::CustomerOrderSerializer

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
