class Companies::Api::V1::TicketSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :ticket_reference, :ticket_type_id, :purchaser_first_name, :purchaser_last_name, :purchaser_email

  def ticket_reference
    object.code
  end

  def ticket_type_id
    object.company_ticket_type_id
  end
end
