module Api
  module V1
    class CustomerSerializer < Api::V1::BaseSerializer
      # attributes :id, :email, :name, :surname, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmed_email, :confirmed_at, :confirmation_sent_at, :has_assigned_gtag, :assigned_gtag, :has_assigned_ticket, :assigned_ticket, :total_credits, :ticket_credits, :purchased_credits, :refundable_amount, :refundable_amount_after_fee, :refundable, :refunded, :refund_status, :completed_claim

      attributes :id, :email, :name, :surname, :created_at, :sign_in_count, :has_assigned_ticket, :assigned_ticket, :has_assigned_gtag, :assigned_gtag, :total_credits, :ticket_credits, :purchased_credits, :refunded, :refund_status, :completed_claim

      def assigned_ticket
        Api::V1::AssignedTicketSerializer.new(object.assigned_admission, scope: scope, root: false)
      end

      def assigned_gtag
        Api::V1::AssignedGtagSerializer.new(object.assigned_gtag_registration, scope: scope, root: false)
      end

      def completed_claim
        Api::V1::CompletedClaimSerializer.new(object.completed_claim, scope: scope, root: false)
      end

      # def current_sign_in_at
      #   object.current_sign_in_at.in_time_zone.strftime("%y-%m-%d %H:%M:%S") if object.current_sign_in_at
      # end

      # def last_sign_in_at
      #   object.last_sign_in_at.in_time_zone.strftime("%y-%m-%d %H:%M:%S") if object.last_sign_in_at
      # end

      # def current_sign_in_ip
      #   object.current_sign_in_ip.to_s
      # end

      # def last_sign_in_ip
      #   object.last_sign_in_ip.to_s
      # end

      # def confirmed_email
      #   !object.confirmed_at.nil?
      # end

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
