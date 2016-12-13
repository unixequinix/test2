class Companies::Api::V1::TicketTypeSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :name, :ticket_type_ref

  def ticket_type_ref
    object.company_code
  end
end
