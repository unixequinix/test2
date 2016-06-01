class Api::V1::TicketWithCustomerSerializer < Api::V1::BaseSerializer
  attributes :reference, :credential_redeemed, :banned, :credential_type_id, :customer,
             :purchaser_first_name, :purchaser_last_name, :purchaser_email

  def reference
    object.code
  end

  def credential_type_id
    object.company_ticket_type&.credential_type_id
  end

  def purchaser_first_name
    object&.purchaser&.first_name
  end

  def purchaser_last_name
    object&.purchaser&.last_name
  end

  def purchaser_email
    object&.purchaser&.email
  end

  def customer
    profile = object.assigned_profile
    return unless profile
    serializer = Api::V1::ProfileSerializer.new(profile)
    ActiveModelSerializers::Adapter::Json.new(serializer).as_json[:profile]
  end
end
