class Api::V1::GtagWithCustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :tag_uid, :credential_redeemed, :banned, :credential_type_id, :customer

  def credential_type_id
    ticket_type = object.company_ticket_type
    ticket_type && ticket_type.credential_type_id
  end

  def customer
    profile = object.assigned_profile
    return unless profile
    serializer = Api::V1::ProfileSerializer.new(profile)
    ActiveModelSerializers::Adapter::Json.new(serializer).as_json[:profile]
  end
end
