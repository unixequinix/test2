class Api::V2::Events::StatsController < Api::V2::BaseController
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
    render json: @stat, serializer: Api::V2::Full::StatSerializer
  end
end
