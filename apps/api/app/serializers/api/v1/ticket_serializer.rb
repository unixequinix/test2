class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  attributes :id, :reference, :credential_redeemed, :credential_type_id

  def attributes(*args)
    hash = super

    if object.customer_id
      hash[:customer_id] = object.customer_id
    else
      hash[:purchaser_first_name] = object.purchaser_first_name if object.purchaser_first_name
      hash[:purchaser_last_name] = object.purchaser_last_name if object.purchaser_last_name
      hash[:purchaser_email] = object.purchaser_email if object.purchaser_email
    end

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

  def purchaser_first_name
    object.purchaser && object.purchaser.first_name
  end

  def purchaser_last_name
    object.purchaser && object.purchaser.last_name
  end

  def purchaser_email
    object.purchaser && object.purchaser.email
  end
end
