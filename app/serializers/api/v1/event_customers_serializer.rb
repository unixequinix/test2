module Api
  module V1
    class EventCustomersSerializer < Api::V1::BaseSerializer
      # attributes :ticket_credits, :purchased_credits, :refund_status
      attributes :customers

      def customers
        customer_query.map do |customer|
          Api::V1::CustomerSerializer.new(customer, scope: scope, root: false)
        end.flatten
      end

      def customer_query
        query = Customer.all
          .includes(:assigned_admission, :assigned_gtag_registration, :completed_claim, :refunds, :credit_logs, :claims, :gtag, :ticket)
      end
    end
  end
end
