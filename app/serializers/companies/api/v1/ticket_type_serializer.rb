class Companies::Api::V1::TicketTypeSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :name, :ticket_type_ref
  attribute :company_code, key: :ticket_type_ref
end
