module Api::V2
  class Simple::TicketSerializer < ActiveModel::Serializer
    attributes :id, :code, :redeemed, :banned, :customer_id, :ticket_type_id
  end
end
