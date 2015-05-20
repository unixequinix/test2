module Api
  module V1
    class TicketSerializer < Api::V1::BaseSerializer
      attributes :ticket_type, :number, :assigned, :customer_assignation_history
      has_one :ticket_type
      has_one :assigned_admission

      def customer_assignation_history
        object.customers.map do |customer|
          "#{customer.name} #{customer.surname} <#{customer.email}>"
        end.join(', ')
      end

      def assigned
        !object.assigned_admission.nil?
      end
    end
  end
end
