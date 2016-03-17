class Companies::Api::V1::BannedTicketSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :ticket_reference

  def ticket_reference
    object.code
  end
end
