module Api
  module V1
    class AssignedGtagSerializer < Api::V1::BaseSerializer
      attributes :gtag_tag_uid, :gtag_tag_serial_number, :gtag_refundable_credits, :gtag_refundable_amount, :gtag_refundable_amount_after_fee, :gtag_refundable?

      def gtag_tag_uid
        object.gtag.tag_uid
      end

      def gtag_tag_serial_number
        object.gtag.tag_serial_number
      end

      def gtag_refundable_credits
        object.gtag.gtag_credit_log.amount unless object.gtag.gtag_credit_log.nil?
      end

      def gtag_refundable_amount
        object.gtag.refundable_amount
      end

      def gtag_refundable_amount_after_fee
        object.gtag.refundable_amount_after_fee
      end

      def gtag_refundable
        object.gtag.refundable?
      end
    end
  end
end
