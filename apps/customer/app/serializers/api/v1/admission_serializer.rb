module Api
  module V1
    class AdmissionSerializer < Api::V1::BaseSerializer
      attributes :number

      def number
        object.ticket.number
      end
    end
  end
end
