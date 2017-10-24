module Api::V2
  class CompanySerializer < ActiveModel::Serializer
    attributes :id, :name, :access_token

    has_many :ticket_types, serializer: TicketTypeSerializer
  end
end
