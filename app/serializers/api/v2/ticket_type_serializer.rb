class Api::V2::TicketTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :company_code

  has_one :company, serializer: Api::V2::CompanySerializer
end
