class Admins::Events::StatsController < Admins::Events::BaseController
  before_action :set_stats

  def stations
    @result = {}
    @current_event.stations.where(category: %w[bar vendor]).each do |station|
      totals = @stats.where(station: station).group(:product_id).sum(:total)
      quantities = @stats.where(station: station).group(:product_id).sum(:product_qty)
      next if totals.empty? || quantities.empty?
      @result[station] = { total: totals, quantity: quantities }
    end
  end

  def cashless
    cookies.signed[:user_id] = current_user.id
  end

  private

  def set_stats
    @stats = @current_event.stats
    authorize(@stats)
  end
end
