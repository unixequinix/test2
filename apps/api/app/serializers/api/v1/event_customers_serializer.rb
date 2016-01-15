module Api
  module V1
    class EventCustomersSerializer < Api::V1::BaseSerializer
      attributes :customer_event_profiles

      def customer_event_profiles
        customer_event_profile_query.map do |customer_event_profile|
          Api::V1::CustomerEventProfileSerializer.new(customer_event_profile, scope: scope, root: false)
        end.flatten
      end

      def customer_event_profile_query
        object.includes(:assigned_admissions,
                        :assigned_gtag_registration,
                        :completed_claim,
                        :refunds,
                        :credit_logs,
                        :claims)
      end
    end
  end
end
