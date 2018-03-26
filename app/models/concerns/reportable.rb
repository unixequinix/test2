module Reportable
  extend ActiveSupport::Concern

  module ClassMethods
    def payment_method
      "coalesce(gateway, 'online') as payment_method"
    end

    def grouper_payment_method
      "payment_method"
    end

    def grouper_event_day
      "event_day"
    end

    def grouper_date_time
      "date_time"
    end

    def grouper_transaction_type
      "action, description, source"
    end

    def dimension_operation
      "NULL as operator_uid, 'Customer' operator_name, 'Customer Portal' as device_name"
    end

    def grouper_dimension_operation
      "operator_uid, operator_name, device_name"
    end

    def dimensions_station
      "'Customer Portal' as location, 'Customer Portal' as station_type, 'Customer Portal' as station_name"
    end

    def grouper_dimensions_station
      "location, station_type, station_name"
    end
  end
end
