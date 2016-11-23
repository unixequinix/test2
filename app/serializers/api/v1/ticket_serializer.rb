class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  attributes :reference, :credential_redeemed, :banned, :catalog_item_id, :customer,
             :purchaser_first_name, :purchaser_last_name, :purchaser_email

  def credential_redeemed
    object.redeemed
  end

  def catalog_item_id
    object.ticket_type&.catalog_item_id
  end

  def customer
    customer = object.customer
    return unless customer
    serializer = Api::V1::CustomerSerializer.new(customer)
    ActiveModelSerializers::Adapter::Json.new(serializer).as_json[:customer]
  end
end
