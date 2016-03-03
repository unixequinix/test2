class Companies::Api::V1::TicketTypeSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :name, :company_ticket_type_ref

  def company_ticket_type_ref
    object.company_code
  end
end
