class Api::V2::TicketSerializer < ActiveModel::Serializer
  attributes :id, :code, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email

  has_one :ticket_type, serializer: Api::V2::TicketTypeSerializer
  has_one :customer, serializer: Api::V2::Simple::CustomerSerializer
end
