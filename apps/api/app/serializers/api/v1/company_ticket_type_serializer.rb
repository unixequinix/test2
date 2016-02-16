class Api::V1::CompanyTicketTypeSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :company_id, :company_ticket_type_ref, :preevent_product_id, :company_name

  def company_name
    object.company.name
  end
end
