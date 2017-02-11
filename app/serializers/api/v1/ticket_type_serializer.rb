class Api::V1::TicketTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :company_id, :company_name, :ticket_type_ref, :catalog_item_id

  def company_name
    object.company.name
  end

  def ticket_type_ref
    object.company_code
  end
end
