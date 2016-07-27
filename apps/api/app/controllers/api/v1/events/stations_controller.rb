class Api::V1::Events::StationsController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]&.to_datetime
    stations = Station.where(event: current_event)
    binding.pry
    stations = stations.where("updated_at > ?", modified) if modified
    date = stations.maximum(:updated_at)&.httpdate

    json = stations.group_by(&:group).map do |group, items|
      { station_group: group, stations: items.map { |s| Api::V1::StationSerializer.new(s) } }
    end

    response.headers["Last-Modified"] = date if date

    status = stations.present? ? 200 : 304 if modified
    status ||= 200
    render(status: status, json: json)
  end
end
