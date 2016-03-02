class Api::V1::GtagSerializer < Api::V1::BaseSerializer
  attributes :id, :tag_uid, :tag_serial_number, :credential_redeemed

  def attributes(*args)
    hash = super
    hash[:customer_id] = customer_id if customer_id
    hash[:credential_type_id] = credential_type_id if credential_type_id
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
end
