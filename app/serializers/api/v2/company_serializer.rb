module Api::V2
  class CompanySerializer < ActiveModel::Serializer
    attributes :id, :name

    has_many :ticket_types, serializer: TicketTypeSerializer
  end
end
