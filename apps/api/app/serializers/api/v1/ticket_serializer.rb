class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  cache key: 'ticket', expires_in: 3.hours
  attributes :id, :reference, :credential_redeemed, :credential_type_id

  def attributes(*args)
    hash = super
    hash[:customer_id] = object.customer_id if object.customer_id
    hash[:purchaser_first_name] = object.purchaser_first_name if object.purchaser_first_name
    hash[:purchaser_last_name] = object.purchaser_last_name if object.purchaser_last_name
    hash[:purchaser_email] = object.purchaser_email if object.purchaser_email
    hash
  end
end
