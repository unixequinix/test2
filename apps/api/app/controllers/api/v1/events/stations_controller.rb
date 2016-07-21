class Api::V1::Events::StationsController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]&.to_datetime
    stations = Station.where(event: current_event)
    stations = stations.where("stations.updated_at > ?", modified + 1) if modified
    date = stations.maximum(:updated_at)&.httpdate

    json = stations.group_by(&:group).map do |group, items|
      { station_group: group, stations: items.map { |s| Api::V1::StationSerializer.new(s) } }
    end

    response.headers["Last-Modified"] = date if date
    render(json: json)
  end
end
