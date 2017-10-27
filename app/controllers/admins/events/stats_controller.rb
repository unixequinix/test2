class Admins::Events::StatsController < Admins::Events::BaseController
  before_action :set_stat, only: %i[edit update update_multiple]
  before_action :set_stats, except: %i[edit update issues]
  before_action :set_filters

  def edit
    @operation = @stat.operation
    authorize(@operation)
    @related_stats = @current_event.stats.where(operation: @operation, error_code: @stat.error_code)
  end

  def update
    if @stat.update(error_code: nil)
      redirect_to issues_admins_event_stats_path(@current_event), notice: t("alerts.updated")
    else
      redirect_to edit_admins_event_stat_path(@current_event, @stat), alert: t("alerts.error")
    end
  end

  def update_multiple
    if @current_event.stats.where(id: params[:ids]).update_all(error_code: nil)
      redirect_to issues_admins_event_stats_path(@current_event), notice: t("alerts.updated")
    else
      redirect_to edit_admins_event_stat_path(@current_event, @stat), alert: t("alerts.error")
    end
  end

  def cashless
    cookies.signed[:user_id] = current_user.id
  end

  def stations
    @result = {}
    @current_event.stations.where(category: %w[bar vendor]).each do |station|
      totals = @stats.where(station: station).group(:product_id).sum(:total)
      quantities = @stats.where(station: station).group(:product_id).sum(:product_qty)
      next if totals.empty? || quantities.empty?
      @result[station] = { total: totals, quantity: quantities }
    end
  end

  def issues
    @q = @current_event.stats.where.not(error_code: nil).ransack(params[:q])
    @all_stats = @q.result
    @error_types = @all_stats.pluck(:error_code).uniq
    @stats = @all_stats.where(error_code: params[:error_type]).order(:date).page(params[:page])

    authorize(@stats)
  end

  private

  def set_stat
    @stat = Stat.find(params[:id])
    authorize(@stat)
  end

  def set_stats
    @stats = @current_event.stats
    authorize(@stats)
  end

  def set_filters
    @stations = params[:stations] if params[:stations].present?
    @start_date = params[:search].present? && params[:search][:start_date].present? ? params[:search][:start_date] : nil
    @end_date = params[:search].present? && params[:search][:end_date].present? ? params[:search][:end_date] : nil
  end
end
