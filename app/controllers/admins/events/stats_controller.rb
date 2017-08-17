class Admins::Events::StatsController < Admins::Events::BaseController
  before_action :set_stats
  before_action :set_filters

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

  private

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
