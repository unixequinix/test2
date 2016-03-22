class Api::V1::EventsController < Api::BaseController
  def index
    @events = Event.all
    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
