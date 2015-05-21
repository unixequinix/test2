module Api
  module V1
    class RefundSerializer < Api::V1::BaseSerializer
      attributes :name, :surname, :email, :gtag_serial_number, :gtag_uid, :bank_account, :amount

      def name
        object.customer.name
      end

      def surname
        object.customer.surname
      end

      def email
        object.customer.email
      end

      def gtag_serial_number
        object.gtag.tag_serial_number
      end

      def gtag_uid
        object.gtag.tag_uid
      end

      def bank_account
        object.bank_account.number
      end

      def amount
        gtag = object.gtag
        gtag.gtag_credit_log.nil? ? 0.0 : gtag.gtag_credit_log.amount
      end
    end
  end
end
