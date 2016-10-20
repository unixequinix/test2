class Api::V1::GtagWithCustomerSerializer < Api::V1::BaseSerializer
  attributes :reference, :banned, :customer

  def reference
    object.tag_uid
  end

  def customer
    profile = object.profile
    return unless profile
    serializer = Api::V1::ProfileSerializer.new(profile)
    ActiveModelSerializers::Adapter::Json.new(serializer).as_json[:profile]
  end
end
