class Api::V1::EventsController < Api::BaseController
  def index
    @events = Event.all
    render json: @events
  end
end
