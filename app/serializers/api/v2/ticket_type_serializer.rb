module Api::V2
  class TicketTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :company_code, :company
  end
end
