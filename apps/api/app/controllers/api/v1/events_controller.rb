class Api::V1::EventsController < Api::BaseController
  def index
    if params[:filter] && params[:filter] == "active"
      @events = Event.where(aasm_state: %w(started launched))
    else
      @events = Event.all
    end
    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
