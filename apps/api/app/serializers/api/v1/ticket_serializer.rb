class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  attributes :id, :credential_type_id, :reference, :credential_redeemed

  def attributes(*args)
    hash = super
    hash[:customer_id] = customer_id if customer_id
    hash
  end

  def credential_type_id
    ticket_type = object.company_ticket_type
    ticket_type && ticket_type.credential_type_id
  end

  def customer_id
    cred = object.credential_assignments.first
    cred && cred.customer_event_profile_id
  end

  def reference
    object.code
  end
end
