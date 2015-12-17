module Api
  module V1
    class CompletedClaimSerializer < Api::V1::BaseSerializer
      attributes :claim_number, :claim_completed_at, :claim_total, :claim_service_type, :claim_fee, :claim_minimum

      def claim_number
        object.number
      end

      def claim_completed_at
        object.completed_at
      end

      def claim_total
        object.total
      end

      def claim_service_type
        object.service_type
      end

      def claim_fee
        object.fee
      end

      def claim_minimum
        object.minimum
      end


    end
  end
end
