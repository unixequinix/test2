module Api
  module V1
    class GtagRegistrationSerializer < Api::V1::BaseSerializer
      attributes :refundable_amount, :refundable_amount_after_fee, :refundable?

      def refundable_amount
        object.gtag.refundable_amount
      end

      def refundable_amount_after_fee
        object.gtag.refundable_amount_after_fee
      end

      def refundable
        object.gtag.refundable?
      end

    end
  end
end
