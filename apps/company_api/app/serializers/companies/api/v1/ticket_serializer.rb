module Companies
  module Api
    module V1
      class TicketSerializer < Companies::Api::V1::BaseSerializer
        attributes :id, :ticket_reference, :purchaser_first_name, :purchaser_last_name,
                   :purchaser_email, :ticket_type_id
                   
        def ticket_reference
          object.number
        end

        def purchaser_first_name
          object.purchaser_name
        end

        def purchaser_last_name
          object.purchaser_surname
        end

        def ticket_type_id
          object.company_ticket_type_id
        end
      end
    end
  end
end
