class Api::V2::TicketSerializer < ActiveModel::Serializer
  attributes :id, :code, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :ticket_type_id, :customer_id
end
