class Api::V2::EventsController < Api::V2::BaseController
  # GET /events/:id
  def show
    authorize(@current_event)
    render json: @current_event
  end
end
