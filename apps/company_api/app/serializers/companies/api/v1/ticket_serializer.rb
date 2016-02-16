class Companies::Api::V1::TicketSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :ticket_reference, :ticket_type_id

  def attributes(*args)
    hash = super

    purchaser = object.purchaser

    if purchaser
      hash[:purchaser_first_name] = purchaser.first_name if purchaser.first_name
      hash[:purchaser_last_name] = purchaser.last_name if purchaser.last_name
      hash[:purchaser_email] = purchaser.email if purchaser.email
    end

    hash
  end

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
