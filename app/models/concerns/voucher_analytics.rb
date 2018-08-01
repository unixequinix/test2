module VoucherAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  def voucher_sales(station_filter: [], credit_filter: [], operator_filter: [])
    pokes.where(action: 'sale').with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).is_ok
  end

  def credit_voucher_sales(grouping: :day, station_filter: [])
    voucher_sales(station_filter: station_filter).group_by_period(grouping, :date).sum(:voucher_amount)
  end

  def voucher_sales_total(station_filter: [])
    voucher_sales(station_filter: station_filter).sum(:voucher_amount)
  end

  def voucher_topups_total(station_filter: [])
    transactions.where(action: "record_access", access_id: voucher_id).with_station(station_filter).status_ok.where("direction > 0").sum(:direction)
  end
end
