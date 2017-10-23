class Admins::Events::StatsController < Admins::Events::BaseController
  before_action :set_stat, only: %i[edit update]
  before_action :set_stats, except: %i[edit update]
  before_action :set_filters

  def edit
    @operation = @stat.operation
  end

  def update
    # TODO[fmoya] make update custom by field depending of error code
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
    @all_stats = Stat.where(event_id: @current_event.id).where.not(error_code: nil)
    @error_types = @all_stats.pluck(:error_code).uniq

    if params[:error_type]
      @stats = @all_stats.where(error_code: params[:error_type]).order(:date) if params[:error_type]
    else
      @stats = []
    end
  end

  private

  def set_stats
    @stats = @current_event.stats
    authorize(@stats)
  end

  def set_stat
    @stat = @current_event.stats.find(params[:id])
    authorize(@stat) if @stat.error_code.present?
  end

  def set_filters
    @stations = params[:stations] if params[:stations].present?
    @start_date = params[:search].present? && params[:search][:start_date].present? ? params[:search][:start_date] : nil
    @end_date = params[:search].present? && params[:search][:end_date].present? ? params[:search][:end_date] : nil
  end
end
