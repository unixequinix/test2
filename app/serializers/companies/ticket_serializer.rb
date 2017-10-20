module Companies
  class TicketSerializer < ActiveModel::Serializer
    attributes :id, :ticket_reference, :ticket_type_id, :purchaser_first_name, :purchaser_last_name, :purchaser_email
  end
end
