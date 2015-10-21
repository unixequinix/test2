module Api
  module V1
    class AssignedTicketSerializer < Api::V1::BaseSerializer
      attributes :ticket_number

      def ticket_number
        object.ticket.number
      end
    end
  end
end
