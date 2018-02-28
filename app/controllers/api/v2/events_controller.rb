module Api::V2
  class EventsController < Api::V2::BaseController
    skip_before_action :verify_event, :put_controller, only: :index

    # GET /events
    def index
      events = policy_scope(Event)
      authorize(events)
      render json: events
    end

    # GET /events/:id
    def show
      authorize(@current_event)
      render json: @current_event
    end
  end
end
