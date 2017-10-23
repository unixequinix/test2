class Stat < StatsBase
  include StatValidator
  include StatFixer

  belongs_to :event
  belongs_to :station, optional: true
  belongs_to :operation, class_name: 'Transaction'

  before_create :validate

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

  enum error_code: { timing_issue: 0, sale_total_quantity: 1, sale_total_price: 2 }

  def self.by_dates(start_date = nil, end_date = nil)
    if start_date && end_date
      where("to_date(date, 'YYYY MM DD') BETWEEN ? AND ?", start_date, end_date)
    elsif start_date
      where("to_date(date, 'YYYY MM DD') = ?", start_date)
    else
      all
    end
  end

  def validate
    self.error_code = StatValidator.validate_all(self)
  end
end
