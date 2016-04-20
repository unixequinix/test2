class Api::V1::TicketWithCustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :reference, :credential_redeemed, :credential_type_id
  has_one :assigned_customer_event_profile,
          key: :customer,
          serializer: Api::V1::CustomerEventProfileSerializer

  def reference
    object.code
  end

  def credential_type_id
    ticket_type = object.company_ticket_type
    ticket_type && ticket_type.credential_type_id
  end
end
