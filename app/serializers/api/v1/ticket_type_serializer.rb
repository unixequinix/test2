class Api::V1::TicketTypeSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :company_id, :company_name, :ticket_type_ref

  def company_id
    object.company_event_agreement.company.id
  end

  def company_name
    object.company_event_agreement.company.name
  end

  def ticket_type_ref
    object.company_code
  end
end
