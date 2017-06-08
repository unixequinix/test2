class Api::V1::Events::StationsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    render(json: [].to_json) && return if @current_event.id.eql?(63)
    stations = @current_event.stations
    stations = stations.where("updated_at > ?", @modified) if @modified
    json = stations.group_by(&:group).map do |group, items|
      { station_group: group, stations: items.map { |s| Api::V1::StationSerializer.new(s) } }
    end
    date = stations.maximum(:updated_at)&.httpdate

    render_entity(json, date)
  end
end
