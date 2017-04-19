class Api::V1::GtagSerializer < ActiveModel::Serializer
  attributes :reference, :redeemed, :banned, :customer

  def customer
    Api::V1::CustomerSerializer.new(object.customer).as_json if object.customer
  end
end
