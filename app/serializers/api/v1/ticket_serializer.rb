class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  attributes :reference, :redeemed, :banned, :catalog_item_id, :customer, :purchaser_first_name, :purchaser_last_name, :purchaser_email

  def catalog_item_id
    object.ticket_type&.catalog_item_id
  end

  def customer
    Api::V1::CustomerSerializer.new(object.customer).as_json if object.customer
  end
end
