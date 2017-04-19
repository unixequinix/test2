class Api::V2::EventsController < Api::V2::BaseController
  skip_before_action :verify_event

  # GET /events/1
  def show
    @event = Event.find_by(slug: params[:id]) || Event.find_by(id: params[:id])
    authorize @event
    render json: @event
  end
end
