module VoucherStationAnalytics
  include BaseAnalytics
  extend ActiveSupport::Concern

  # POS Voucher
  #
  def pos_vouchers(product_filter: [])
    pokes.where(action: 'sale').where("voucher_amount > 0").with_product(product_filter).is_ok
  end

  def credit_pos_vouchers(grouping: :day, product_filter: [])
    pos_vouchers(product_filter: product_filter).group_by_period(grouping, :date).sum("voucher_amount")
  end
end
