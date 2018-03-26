module Api::V2
  class Full::TicketTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :company_code, :company

    has_many :tickets, serializer: Simple::TicketSerializer
  end
end
