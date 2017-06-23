class Api::V1::EventsController < Api::V1::BaseController
  def index
    @events = params[:filter].to_s.eql?("active") ? Event.where(state: :launched) : Event.all
    @events = @events.where(open_api: true)
    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
