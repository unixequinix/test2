module Api
  module V1
    class TicketSerializer < Api::V1::BaseSerializer
      attributes :ticket_type, :number, :assigned, :customer_assignation_history, :purchaser_email, :purchaser_name, :purchaser_surname, :created_at
      has_one :ticket_type
      has_one :assigned_admission

      def customer_assignation_history
        object.customer_event_profiles.map do |customer_event_profile|
          "#{customer_event_profile.customer.name} #{customer_event_profile.customer.surname} <#{customer_event_profile.customer.email}>"
        end.join(', ')
      end

      def assigned
        !object.assigned_admission.nil?
      end

      def created_at
        object.created_at.in_time_zone.strftime("%y-%m-%d %H:%M:%S") if object.created_at
      end
    end
  end
end
