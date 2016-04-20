class Api::V1::TicketWithCustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :reference, :credential_redeemed, :credential_type_id, :customer

  def reference
    object.code
  end

  def credential_type_id
    ticket_type = object.company_ticket_type
    ticket_type && ticket_type.credential_type_id
  end

  def customer
    serializer = Api::V1::CustomerEventProfileSerializer.new(object.assigned_customer_event_profile)
    ActiveModel::Serializer::Adapter::Json.new(serializer).as_json[:customer_event_profile]
  end
end
