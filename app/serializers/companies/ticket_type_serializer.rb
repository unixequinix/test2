module Companies
  class TicketTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :ticket_type_ref
    attribute :company_code, key: :ticket_type_ref
  end
end
