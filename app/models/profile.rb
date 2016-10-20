# == Schema Information
#
# Table name: profiles
#
#  id                       :integer          not null, primary key
#  customer_id              :integer
#  event_id                 :integer          not null
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  banned                   :boolean          default(FALSE)
#  credits                  :decimal(8, 2)    default(0.0)
#  refundable_credits       :decimal(8, 2)    default(0.0)
#  final_balance            :decimal(8, 2)    default(0.0)
#  final_refundable_balance :decimal(8, 2)    default(0.0)
#

class Profile < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  acts_as_paranoid
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :customer
  belongs_to :event
  has_many :tickets
  has_many :gtags
  has_one :active_gtag, -> { where(active: true) }, class_name: "Gtag"
  has_many :orders
  has_many :claims
  has_many :refunds, through: :claims
  has_many :customer_orders
  has_many :payments, through: :orders
  has_many :transactions
  has_many :completed_claims, -> { where(aasm_state: :completed).where.not(completed_at: nil) }, class_name: "Claim"
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_many :payment_gateway_customers

  validates :event, presence: true

  scope :with_gtag, -> { includes(:gtags).where.not(gtags: { profile_id: nil }) }

  scope :query_for_csv, lambda { |event|
    where(event: event)
      .joins("LEFT OUTER JOIN customers ON profiles.customer_id = customers.id")
      .joins(:tickets)
      .joins(:gtags)
      .select("profiles.id, tickets.code as ticket, gtags.tag_uid as gtag, profiles.credits as credits,
               profiles.refundable_credits as refundable_credits, customers.email, customers.first_name,
               customers.last_name")
      .group("profiles.id, customers.first_name, customers.id, tickets.code, gtags.tag_uid")
      .order("customers.first_name ASC")
  }

  def recalculate_balance
    ts = transactions.credit.status_ok
    has_onsite_ts = ts.sum(:gtag_counter) != 0

    self.credits = ts.not_record_credit.sum(:credits)
    self.refundable_credits = ts.not_record_credit.sum(:refundable_credits)
    # TODO: The conditional is because of a bug when buying multiple items online, there are several
    #       transactions and the previous are taken into account when calculating the final balances
    self.final_balance = has_onsite_ts ? ts.last.final_balance : credits
    self.final_refundable_balance = has_onsite_ts ? ts.last.final_refundable_balance : refundable_credits

    save
  end

  def credentials
    gtags + tickets
  end

  def active_credentials
    [active_gtag, tickets].flatten.compact
  end

  def customer
    Customer.unscoped { super }
  end

  def all_transaction_counters
    transactions.pluck(:gtag_counter).map(&:to_i).sort
  end

  def all_online_counters
    transactions.pluck(:counter).map(&:to_i).sort
  end

  def enough_money?
    refundable_money <= online_refundable_money
  end

  def missing_transaction_counters
    (1..all_transaction_counters.last.to_i).to_a - all_transaction_counters
  end

  def active_credentials?
    tickets.any? || active_gtag.present?
  end

  def refundable?(refund_service)
    minimum = event.refund_minimun(refund_service).to_f
    amount = refundable_money_after_fee(refund_service)
    amount >= minimum && amount.positive?
  end

  def refundable_money
    refundable_credits * event.standard_credit_price
  end

  def refundable_money_after_fee(refund_service)
    refundable_money - event.refund_fee(refund_service).to_f
  end

  def online_refundable_money
    payments.where(payment_type: Payment::DIRECT_TYPES).sum(:amount)
  end

  def valid_balance?
    credits == final_balance && refundable_credits == final_refundable_balance
  end

  def purchases
    atts = %w( id name catalogable_type catalogable_id ).map { |k| "catalog_items.#{k}" }.join(", ")
    customer_orders.joins(:catalog_item).select("sum(customer_orders.amount) as total_amount, #{atts}").group(atts)
  end

  def infinite_entitlements_purchased
    single = customer_orders.includes(catalog_item: :catalogable).select do |customer_order|
      customer_order.catalog_item.catalogable.try(:entitlement).try(:infinite?)
    end.map(&:catalog_item_id)

    packs_ids = Pack.joins(:catalog_items_included).where(catalog_items: { id: single })
    pack = CatalogItem.where(catalogable_id: packs_ids, catalogable_type: "Pack").pluck(:id)

    single + pack
  end

  def sorted_purchases(**params)
    Sorters::PurchasesSorter.new(purchases).sort(params)
  end

  def gateway_customer(gateway)
    payment_gateway_customers.find_by(gateway_type: gateway)
  end

  def self.counters(event) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(cust)))
      FROM (
        SELECT
          customer_trans.profile_id ,
          MAX(customer_trans.gtag_counter) as gtag,
          SUM(customer_trans.gtag_counter) as gtag_total,
          MAX(customer_trans.gtag_counter) * (MAX(customer_trans.gtag_counter) + 1) / 2 as gtag_last_total,
          MAX(customer_trans.counter) as online,
          SUM(customer_trans.counter) as online_total,
          MAX(customer_trans.counter) * (MAX(customer_trans.counter) + 1) / 2 as online_last_total
        FROM (
          SELECT profile_id, gtag_counter, counter
          FROM transactions
          WHERE event_id = #{event.id} AND status_code = 0
        ) customer_trans
        GROUP BY customer_trans.profile_id
        ORDER BY customer_trans.profile_id
      ) cust
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    JSON.parse(sql).to_a.group_by { |t| t["profile_id"] }
  end

  def self.credits_sum(event) # rubocop:disable Metrics/MethodLength
    sql = <<-SQL
      SELECT to_json(json_agg(row_to_json(inc)))
      FROM (
        SELECT
          id as profile_id,
          credits,
          refundable_credits,
          final_balance,
          final_refundable_balance,
          final_balance - credits as inconsistent,
          final_refundable_balance - refundable_credits as inconsistent_refundable
        FROM profiles
        WHERE event_id = #{event.id} AND
              (final_balance <> credits OR final_refundable_balance <> refundable_credits)
        AND deleted_at IS NULL
        ORDER BY inconsistent DESC
      ) inc
    SQL
    conn = ActiveRecord::Base.connection
    sql = conn.select_value(sql)
    conn.close
    JSON.parse(sql).to_a
  end
end
