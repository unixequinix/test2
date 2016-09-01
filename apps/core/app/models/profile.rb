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
  has_many :orders
  has_many :claims
  has_many :refunds, through: :claims
  has_many :customer_orders
  has_many :online_orders, through: :customer_orders
  has_many :payments, through: :orders
  has_many :ban_transactions
  has_many :credit_transactions
  has_many :access_transactions
  has_many :credential_transactions
  has_many :money_transactions
  has_many :order_transactions
  has_many :completed_claims, -> { where("aasm_state = 'completed' AND completed_at IS NOT NULL") }, class_name: "Claim"
  has_many :credential_assignments
  # credential_assignments_tickets
  has_many :ticket_assignments, -> { where(credentiable_type: "Ticket") },
           class_name: "CredentialAssignment", dependent: :destroy
  # credential_assignments_gtags
  has_many :gtag_assignments, -> { where(credentiable_type: "Gtag") },
           class_name: "CredentialAssignment", dependent: :destroy
  # credential_assignments_assigned
  has_many :active_assignments, -> { where(aasm_state: :assigned) }, class_name: "CredentialAssignment"
  # credential_assignments_tickets_assigned
  has_many :active_tickets_assignment, -> { where(aasm_state: :assigned, credentiable_type: "Ticket") },
           class_name: "CredentialAssignment"
  # credential_assignments_gtag_assigned
  has_one :active_gtag_assignment, -> { where(aasm_state: :assigned, credentiable_type: "Gtag") },
          class_name: "CredentialAssignment"
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_many :payment_gateway_customers

  # Validations
  validates :event, presence: true

  # Scopes
  scope :for_event, -> (event) { where(event: event) }
  scope :with_gtag, lambda { |event|
    joins(:credential_assignments)
      .where(event: event, credential_assignments: { credentiable_type: "Gtag", aasm_state: :assigned })
  }

  scope :query_for_csv, lambda { |event|
    where(event: event)
      .joins("LEFT OUTER JOIN customers ON profiles.customer_id = customers.id")
      .joins(:credential_assignments)
      .joins("LEFT OUTER JOIN tickets
              ON credential_assignments.credentiable_id = tickets.id
              AND credential_assignments.aasm_state = 'assigned'
              AND credential_assignments.credentiable_type = 'Ticket'")
      .joins("LEFT OUTER JOIN gtags
              ON credential_assignments.credentiable_id = gtags.id
              AND credential_assignments.aasm_state = 'assigned'
              AND credential_assignments.credentiable_type = 'Gtag'")
      .select("profiles.id, tickets.code as ticket, gtags.tag_uid as gtag, profiles.credits as credits,
               profiles.refundable_credits as refundable_credits, customers.email, customers.first_name,
               customers.last_name")
      .group("profiles.id, customers.first_name, customers.id, tickets.code, gtags.tag_uid")
      .order("customers.first_name ASC")
  }

  def customer
    Customer.unscoped { super }
  end

  def transactions(sort)
    transactions = credit_transactions
    transactions += access_transactions
    transactions += credential_transactions
    transactions += money_transactions
    transactions += order_transactions
    transactions += ban_transactions
    # TODO: Its a workaround for sorting, remove after picnik is fixed
    #transactions.sort_by! { |t| [t.gtag_counter, t.counter] } if sort.eql?("counters") || sort.nil?
    #transactions.sort_by! { |t| [t.device_created_at, t.gtag_counter, t.counter] } if sort.eql?("date")
    transactions
  end

  def all_transaction_counters
    indexes = credit_transactions.map(&:gtag_counter).map(&:to_i)
    indexes += access_transactions.map(&:gtag_counter).map(&:to_i)
    indexes += credential_transactions.map(&:gtag_counter).map(&:to_i)
    indexes += money_transactions.map(&:gtag_counter).map(&:to_i)
    indexes += order_transactions.map(&:gtag_counter).map(&:to_i)
    indexes += ban_transactions.map(&:gtag_counter).map(&:to_i)
    indexes.sort
  end

  def all_online_counters
    indexes = credit_transactions.map(&:counter)
    indexes += access_transactions.map(&:counter)
    indexes += credential_transactions.map(&:counter)
    indexes += money_transactions.map(&:counter)
    indexes += order_transactions.map(&:counter)
    indexes += ban_transactions.map(&:counter)
    indexes.sort
  end

  def missing_transaction_counters
    indexes = all_transaction_counters
    all_indexes = (1..indexes.last.to_i).to_a
    (all_indexes - indexes).sort
  end

  def active_credentials?
    active_tickets_assignment.any? || active_gtag_assignment.present?
  end

  def refundable?(refund_service)
    minimum = event.refund_minimun(refund_service).to_f
    amount = refundable_money_after_fee(refund_service)
    amount >= minimum && amount >= 0
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
    transactions_select = Transaction::TYPES.map do |t|
      "SELECT profile_id, gtag_counter, counter FROM #{t}_transactions WHERE event_id = #{event.id} AND status_code = 0"
    end.join(" UNION ALL ")

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
        FROM (#{transactions_select}) customer_trans
        GROUP BY customer_trans.profile_id
        ORDER BY customer_trans.profile_id
      ) cust
    SQL

    JSON.parse(ActiveRecord::Base.connection.select_value(sql)).to_a.group_by { |t| t["profile_id"] }
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
        ORDER BY inconsistent DESC
      ) inc
    SQL
    JSON.parse(ActiveRecord::Base.connection.select_value(sql)).to_a
  end
end
