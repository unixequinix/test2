class Stat < StatsBase
  belongs_to :event
  belongs_to :station

  scope :topups, -> { where(action: "topup") }
  scope :refunds, -> { where(action: "refund") }
  scope :sales, -> { where(action: "sale") }
  scope :sale_refunds, -> { where(action: "sale_refund") }
  scope :initial_fees, -> { where(action: "initial_fee") }
  scope :topup_fees, -> { where(action: "topup_fee") }
  scope :deposit_fees, -> { where(action: "gtag_deposit_fee") }
  scope :return_fees, -> { where(action: "gtag_return_fee") }

  scope :onsite, -> { where(source: "onsite") }
  scope :online, -> { where(source: %w[customer_portal admin_panel]) }

  validates :source, :transaction_id, :transaction_counter, :event_name, :credit_name, :credit_value, :action, :station_name, :station_category, :date, :total, :payment_method, presence: true # rubocop:disable Metrics/LineLength

  def self.by_dates(start_date = nil, end_date = nil)
    if start_date && end_date
      where("to_date(date, 'YYYY MM DD') BETWEEN ? AND ?", start_date, end_date)
    elsif start_date
      where("to_date(date, 'YYYY MM DD') = ?", start_date)
    else
      all
    end
  end
end
