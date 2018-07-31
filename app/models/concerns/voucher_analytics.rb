module VoucherAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  def voucher_sales(station_filter: [], credit_filter: [], operator_filter: [])
    pokes.where(action: 'sale').with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).is_ok
  end

  def credit_voucher_sales(grouping: :day, station_filter: [])
    voucher_sales(station_filter: station_filter).group_by_period(grouping, :date).sum(:voucher_amount)
  end
end
