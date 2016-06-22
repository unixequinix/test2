# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  event_id    :integer          not null
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  banned      :boolean          default(FALSE)
#

class Profile < ActiveRecord::Base
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
  has_many :credit_transactions
  has_many :access_transactions
  has_many :credential_transactions
  has_many :money_transactions
  has_many :order_transactions
  has_many :customer_credits
  has_many :completed_claims, -> { where("aasm_state = 'completed' AND completed_at IS NOT NULL") },
           class_name: "Claim"
  has_many :credit_purchased_logs,
           -> { where(transaction_origin: CustomerCredit::CREDITS_PURCHASE) },
           class_name: "CustomerCredit"
  has_many :credential_assignments
  # credential_assignments_tickets
  has_many :ticket_assignments,
           -> { where(credentiable_type: "Ticket") },
           class_name: "CredentialAssignment", dependent: :destroy
  # credential_assignments_gtags
  has_many :gtag_assignments,
           -> { where(credentiable_type: "Gtag") },
           class_name: "CredentialAssignment", dependent: :destroy
  # credential_assignments_assigned
  has_many :active_assignments,
           -> { where(aasm_state: :assigned) }, class_name: "CredentialAssignment"
  # credential_assignments_tickets_assigned
  has_many :active_tickets_assignment,
           -> { where(aasm_state: :assigned, credentiable_type: "Ticket") },
           class_name: "CredentialAssignment"
  # credential_assignments_gtag_assigned
  has_one :active_gtag_assignment,
          -> { where(aasm_state: :assigned, credentiable_type: "Gtag") },
          class_name: "CredentialAssignment"
  has_one :completed_claim,
          -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_many :payment_gateway_customers

  # Validations
  validates :event, presence: true

  # Scopes
  scope :for_event, -> (event) { where(event: event) }
  scope :with_gtag, lambda { |event|
    joins(:credential_assignments)
      .where(event: event,
             credential_assignments: { credentiable_type: "Gtag", aasm_state: :assigned })
  }

  def customer
    Customer.unscoped { super }
  end

  def all_transaction_counters
    indexes = credit_transactions.map(&:gtag_counter)
    indexes += access_transactions.map(&:gtag_counter)
    indexes += credential_transactions.map(&:gtag_counter)
    indexes += money_transactions.map(&:gtag_counter)
    indexes += order_transactions.map(&:gtag_counter)
    indexes.sort
  end

  def missing_transaction_counters
    indexes = all_transaction_counters
    all_indexes = (1..indexes.last.to_i).to_a
    (all_indexes - indexes).sort
  end

  def active_credentials?
    active_tickets_assignment.any? || !active_gtag_assignment.nil?
  end

  # TODO: check with customer_credits.current method for duplication
  def current_balance
    customer_credits.order(created_in_origin_at: :desc).first
  end

  def total_credits
    customer_credits.sum(:amount)
  end

  def total_refundable
    customer_credits.sum(:refundable_amount)
  end

  def ticket_credits
    customer_credits.where.not(transaction_origin: CustomerCredit::CREDITS_PURCHASE)
                    .sum(:amount).floor
  end

  def purchased_credits
    customer_credits.where(transaction_origin: CustomerCredit::CREDITS_PURCHASE).sum(:amount).floor
  end

  def refundable_credits_amount
    current_balance.present? ? current_balance.final_refundable_balance : 0
  end

  # TODO: should this method be here??
  def refundable_money_amount
    refundable_credits_amount * event.standard_credit_price
  end

  def refundable_amount_after_fee(refund_service)
    fee = event.refund_fee(refund_service)
    refundable_money_amount - fee.to_f
  end

  def online_refundable_money_amount
    payments.sum(:amount)
  end

  def purchases
    customer_orders.joins(:catalog_item).select("sum(customer_orders.amount) as total_amount,
                                                 catalog_items.id,
                                                 catalog_items.name,
                                                 catalog_items.catalogable_type,
                                                 catalog_items.catalogable_id")
                   .group("catalog_items.name, catalog_items.catalogable_type, "\
             "catalog_items.catalogable_id, catalog_items.id")
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
end
