module Api::V2
  class Events::StatsController < BaseController
    # GET api/v2/events/:event_id/stats
    def index
      @stats = Stat.where(event: @current_event)
      authorize @stats

      paginate json: @stats
    end

    # GET api/v2/events/:event_id/stats/:id
    def show
      @stat = Stat.find_by!(id: params[:id], event: @current_event)
      authorize @stat
      render json: @stat, serializer: Full::StatSerializer
    end
  end
end
