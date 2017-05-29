class Api::V1::EventsController < Api::BaseController
  def index
    @events = params[:filter].to_s.eql?("active") ? Event.where(state: :launched) : Event.all
    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
