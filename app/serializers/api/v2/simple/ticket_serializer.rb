class Api::V2::Simple::TicketSerializer < ActiveModel::Serializer
  attributes :id, :code, :redeemed, :banned, :customer_id, :ticket_type_id
end
