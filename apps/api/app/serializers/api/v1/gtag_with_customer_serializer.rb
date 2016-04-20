class Api::V1::GtagWithCustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :tag_uid, :tag_serial_number, :credential_redeemed
  has_one :assigned_customer_event_profile,
          key: :customer,
          serializer: Api::V1::CustomerEventProfileSerializer

  def credential_type_id
    ticket_type = object.company_ticket_type
    ticket_type && ticket_type.credential_type_id
  end

  def customer_id
    cred = object.credential_assignments.first
    cred && cred.customer_event_profile_id
  end

end
