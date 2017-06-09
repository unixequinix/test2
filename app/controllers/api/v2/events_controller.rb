class Api::V2::EventsController < Api::V2::BaseController

  # GET /events/1
  def show
    authorize(@current_event)
    render json: @current_event
  end
end
