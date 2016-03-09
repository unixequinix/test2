class Api::V1::Events::StationsController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.stations, each_serializer: Api::V1::StationGroupSerializer
  end
end
