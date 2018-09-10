module Api::V2
  class EventsController < Api::V2::BaseController
    before_action :set_paper_trail_whodunnit

    skip_before_action :verify_event, :set_metric, only: :index
    skip_after_action :update_metric_response

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

    # PATCH/PUT api/v2/events/:event_id/accesses/:id
    def update
      authorize(@current_event)
      if @current_event.update(event_params)
        render json: @current_event
      else
        render json: @current_event.errors, status: :unprocessable_entity
      end
    end

    private

    def event_params
      params.require(:event).permit(:every_onsite_topup_fee, :every_online_topup_fee, :onsite_initial_topup_fee, :online_initial_topup_fee, :gtag_deposit_fee, :online_refund_fee, :maximum_gtag_balance)
    end
  end
end
