class Stat < StatsBase
  # rubocop:disable all
  include StatValidator

  belongs_to :event, counter_cache: true
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

  scope :money_recon, -> { select(:action, :station_name, :monetary_total_price, :payment_method, event_day_query).where("monetary_total_price IS NOT NULL") }
  scope :money_recon_operators, -> { select(:action, :station_name, :monetary_total_price, :payment_method, :operator_uid, :operator_name, :device_name, event_day_query).where("monetary_total_price IS NOT NULL") }

  scope :devices, -> { select(:station_name, event_day_query, "count(distinct device_id) as total_devices").group(:station_name, :event_day)}

  scope :credit_flow, -> { select(:action, :station_type, :station_name, :credit_name, :credit_amount, :device_name, event_day_query).where("credit_amount IS NOT NULL") }

  scope :products_sale, -> { select(:station_type, :station_name, :product_name, :credit_name, event_day_query, :operator_uid, :operator_name, :device_name, "sum(credit_amount)*-1 as credit_amount", "sum(sale_item_quantity) as sale_item_quantity")
                                 .where("action in ('sale', 'sale_refund')")
                                 .group(:station_type, :station_name, :product_name, :credit_name, "to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY')", :operator_uid, :operator_name, :device_name) }

  scope :checkin_ticket_type, -> { select(:action, :station_type, :station_name, :ticket_type_name, event_day_query, :operator_uid, :operator_name, :device_name, "count(id) as total_tickets")
                                       .where("action in ('checkin')")
                                       .group(:action, :station_type, :station_name, :ticket_type_name, "to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY')", :operator_uid, :operator_name, :device_name) }

  scope :access, -> { select(:station_type, :station_name, event_day_query, "to_char(date_trunc('hour', date), 'DD-MM-YYYY HHh') as date_time", "CASE access_direction WHEN 1 THEN 'OUT' WHEN -1 THEN 'IN' END as direction", "sum(access_direction) as access_direction")
                          .where("access_direction IS NOT NULL")
                          .group(:station_type, :station_name, "to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY')", "to_char(date_trunc('hour', date), 'DD-MM-YYYY HHh')", "CASE access_direction WHEN 1 THEN 'OUT' WHEN -1 THEN 'IN' END")}

  has_paper_trail on: %i[update destroy]

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

  def self.event_day_query
    "to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day"
  end

  def validate
    self.error_code = StatValidator.validate_all(self)
  end
end
