class Api::V2::Events::StatsController < Api::V2::BaseController
  # GET /stats
  def index
    @stats = Stat.where(event: @current_event)
    authorize @stats

    render json: @stats
  end

  # GET /stats/1
  def show
    @stat = Stat.find_by!(id: params[:id], event: @current_event)
    authorize @stat
    render json: @stat, serializer: Api::V2::Full::StatSerializer
  end
end