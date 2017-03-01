class Api::V1::GtagSerializer < ActiveModel::Serializer
  attributes :reference, :banned, :customer

  def catalog_item_id
    object.ticket_type&.catalog_item_id
  end

  def customer
    Api::V1::CustomerSerializer.new(object.customer).as_json if object.customer
  end
end
