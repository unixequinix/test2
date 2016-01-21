module Companies
  module Api
    module V1
      class TicketTypeSerializer < Companies::Api::V1::BaseSerializer
        attributes :id, :name, :company_ticket_type_ref
      end
    end
  end
end
