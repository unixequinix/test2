module Api
  module V1
    class CustomerEventProfileSerializer < Api::V1::BaseSerializer
      has_one :customer
      attributes :id, :has_assigned_ticket, :assigned_ticket, :has_assigned_gtag, :assigned_gtag, :total_credits, :ticket_credits, :purchased_credits, :refunded, :refund_status, :completed_claim

      def assigned_ticket
        Api::V1::AssignedTicketSerializer.new(object.assigned_admission, scope: scope, root: false)
      end

      def assigned_gtag
        Api::V1::AssignedGtagSerializer.new(object.assigned_gtag_registration, scope: scope, root: false)
      end

      def completed_claim
        Api::V1::CompletedClaimSerializer.new(object.completed_claim, scope: scope, root: false)
      end

      def has_assigned_ticket
        assigned_admission ? true : false
      end

      def has_assigned_gtag
        assigned_gtag_registration ? true : false
      end

      def refunded
        !object.completed_claim.nil?
      end


      def total_credits
        object.credit_logs.sum(:amount).floor
      end

      def ticket_credits
        object.credit_logs.where.not(transaction_type: CreditLog::CREDITS_PURCHASE).sum(:amount).floor
      end

      def purchased_credits
        object.credit_logs.where(transaction_type: CreditLog::CREDITS_PURCHASE).sum(:amount).floor
      end

      private

      def assigned_gtag_registration
        @assigned_gtag_registration ||= object.assigned_gtag_registration
      end

      def assigned_admission
        @assigned_admission ||= object.assigned_admission
      end

      def refund_status
        object.claims.any? ? get_refund_status : "NOT TRIGGERED"
      end

      def get_refund_status
        object.claims.any? && object.completed_claim.nil? ? "NOT FINISHED" : object.completed_claim.refund.status
      end

    end
  end
end
