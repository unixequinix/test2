module Api
  module V1
    class CustomerSerializer < Api::V1::BaseSerializer
      attributes :id, :email, :name, :surname, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmed_email, :confirmed_at, :confirmation_sent_at, :assigned_gtag, :assigned_ticket, :total_credits, :ticket_credits, :purchased_credits, :refundable_credits, :refunded, :refund_status, :completed_claim

      def current_sign_in_ip
        object.current_sign_in_ip.to_s
      end

      def last_sign_in_ip
        object.last_sign_in_ip.to_s
      end

      def current_sign_in_at
        object.current_sign_in_at.in_time_zone.strftime("%y-%m-%d %H:%M:%S") if object.current_sign_in_at
      end

      def last_sign_in_at
        object.last_sign_in_at.in_time_zone.strftime("%y-%m-%d %H:%M:%S") if object.last_sign_in_at
      end

      def confirmed_email
        !object.confirmed_at.nil?
      end

      def assigned_gtag
        object.assigned_gtag_registration.gtag if object.assigned_gtag_registration
      end

      def assigned_ticket
        object.assigned_admission.ticket if object.assigned_admission
      end

      def refunded
        !object.completed_claim.nil?
      end

      def refund_status
        object.claims.any? ? get_refund_status : "NOT TRIGGERED"
      end

      private

      def get_refund_status
        object.claims.any? && object.completed_claim.nil? ? "NOT FINISHED" : object.completed_claim.refund.status
      end
    end
  end
end
