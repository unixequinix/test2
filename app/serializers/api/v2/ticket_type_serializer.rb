class Api::V2::TicketTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :company_code, :company_id
end
