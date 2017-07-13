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
    @payment_methods = @stats.select(:payment_method).distinct.pluck(:payment_method).sort

    @online_topups = @stats.topups.online.group(:payment_method).sum(:total)
    @onsite_topups = @stats.topups.onsite.group(:payment_method).sum(:total)

    @online_refunds = @stats.refunds.online.group(:payment_method).sum(:total)
    @onsite_refunds = @stats.refunds.onsite.group(:payment_method).sum(:total)

    @sales = @stats.sales.onsite.group(:payment_method).sum(:total)
    @sale_refunds = @stats.sale_refunds.group(:payment_method).sum(:total)

    @initial_fees = @stats.initial_fees.group(:payment_method).sum(:total)
    @topup_fees = @stats.topup_fees.group(:payment_method).sum(:total)
    @deposit_fees = @stats.deposit_fees.group(:payment_method).sum(:total)
    @return_fees = @stats.return_fees.group(:payment_method).sum(:total)
  end

  private

  def set_stats
    @stats = @current_event.stats
    authorize(@stats)
  end
end
