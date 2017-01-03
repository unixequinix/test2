class Api::V1::GtagSerializer < Api::V1::BaseSerializer
  attributes :reference, :banned, :customer

  def customer
    Api::V1::CustomerSerializer.new(object.customer).as_json if object.customer
  end
end
