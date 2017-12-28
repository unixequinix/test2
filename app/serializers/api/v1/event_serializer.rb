module Api
  module V1
    class EventSerializer < ActiveModel::Serializer
      attributes :id, :name, :start_date, :end_date, :staging_start, :staging_end

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
