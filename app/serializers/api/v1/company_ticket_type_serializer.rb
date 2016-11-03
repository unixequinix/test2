class Api::V1::CompanyTicketTypeSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :company_id, :credential_type_id, :company_name, :company_ticket_type_ref

  def company_id
    object.company_event_agreement.company.id
  end

  def company_name
    object.company_event_agreement.company.name
  end

  def company_ticket_type_ref
    object.company_code
  end
end