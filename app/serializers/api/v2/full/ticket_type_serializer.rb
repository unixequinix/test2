class Api::V2::Full::TicketTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :company_code, :company_id

  has_many :tickets, serializer: Api::V2::Simple::TicketSerializer
end
