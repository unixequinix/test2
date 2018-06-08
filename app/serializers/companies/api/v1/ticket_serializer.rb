class Companies::Api::V1::TicketSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :ticket_type_id, :purchaser_first_name, :purchaser_last_name, :purchaser_email
  attribute :code, as: :ticket_reference
end
