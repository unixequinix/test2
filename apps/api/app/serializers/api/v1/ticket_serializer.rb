class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  attributes :id, :reference, :credential_redeemed, :credential_type_id, :purchaser_first_name,
             :purchaser_last_name, :purchaser_email

  def reference
    object.code
  end

  def credential_type_id
    object&.company_ticket_type&.credential_type_id
  end

  def customer_id
    object&.assigned_customer_event_profile&.id
  end

  def purchaser_first_name
    object&.purchaser&.first_name
  end

  def purchaser_last_name
    object&.purchaser&.last_name
  end

  def purchaser_email
    object&.purchaser&.email
  end
end
