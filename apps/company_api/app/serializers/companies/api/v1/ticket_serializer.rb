class Companies::Api::V1::TicketSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :ticket_reference, :purchaser_first_name, :purchaser_last_name,
             :purchaser_email, :ticket_type_id

  def ticket_reference
    object.code
  end

  def ticket_type_id
    object.company_ticket_type_id
  end

  def purchaser_first_name
    object.purchaser.first_name
  end

  def purchaser_last_name
    object.purchaser.last_name
  end

  def purchaser_email
    object.purchaser.email
  end
end
