module Api
  module V1
    module Events
      class StationsController < Api::V1::EventsController
        before_action :set_modified

        def index
          stations = @current_event.stations
          stations = stations.where("updated_at > ?", @modified) if @modified

          json = stations.group_by(&:group).map { |group, items| { station_group: group, stations: items.map { |s| StationSerializer.new(s) } } }
          date = stations.maximum(:updated_at)&.httpdate

          render_entity(json, date)
        end
      end
    end
  end
end
