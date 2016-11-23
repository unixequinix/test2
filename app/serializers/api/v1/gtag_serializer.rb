class Api::V1::GtagSerializer < Api::V1::BaseSerializer
  attributes :reference, :banned, :customer

  def customer
    customer = object.customer
    return unless customer
    serializer = Api::V1::CustomerSerializer.new(customer)
    ActiveModelSerializers::Adapter::Json.new(serializer).as_json[:customer]
  end
end
