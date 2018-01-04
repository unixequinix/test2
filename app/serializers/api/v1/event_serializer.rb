module Api
  module V1
    class EventSerializer < ActiveModel::Serializer
      attributes :id, :name, :initialization_type, :start_date, :end_date, :staging_start, :staging_end

      def initialization_type
        device = instance_options[:serializer_params][:device]

        DeviceRegistration.find_by(device_id: device.id, event_id: object.id)&.action&.downcase
      end

      def start_date
        Time.use_zone(object.timezone) { object.start_date }
      end

      def end_date
        Time.use_zone(object.timezone) { object.end_date }
      end

      def staging_start
        Time.use_zone(object.timezone) { object.start_date - 7.days }
      end

      def staging_end
        Time.use_zone(object.timezone) { object.end_date + 7.days }
      end
    end
  end
end
