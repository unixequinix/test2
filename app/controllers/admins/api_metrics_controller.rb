module Admins
  class ApiMetricsController < BaseController
    before_action :authorize_glowball

    def index
      @q = Event.where(id: ApiMetric.select(:event_id).distinct.pluck(:event_id)).ransack(params[:q])
      @events = @q.result.order(start_date: :desc, name: :asc)
    end

    def show
      @event = Event.friendly.find(params[:id])
      @api_metrics = @event.api_metrics.group(:user_id, :controller, :action).count
    end

    private

    def authorize_glowball
      authorize(:api_metrics, :all?)
    end
  end
end
