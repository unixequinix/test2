class Api::V1::CompanyTicketTypeSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :company_id, :catalog_item_id, :company_name, :company_ticket_type_ref

  def company_id
    object.company_event_agreement.company.id
  end

  def company_name
    object.company_event_agreement.company.name
  end

  def catalog_item_id
    object.credential_type.catalog_item_id
  end

  def company_ticket_type_ref
    object.company_code
  end
end
