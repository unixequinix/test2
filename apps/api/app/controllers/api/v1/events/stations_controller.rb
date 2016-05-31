class Api::V1::Events::StationsController < Api::V1::Events::BaseController
  def index
    json = Station.where(event: current_event).group_by(&:group).map do |group, stations|
      { station_group: group, stations: stations.map { |s| Api::V1::StationSerializer.new(s) } }
    end
    render json: json
  end
end
