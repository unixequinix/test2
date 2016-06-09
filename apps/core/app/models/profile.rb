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
  has_many :completed_claims, -> { where("aasm_state = 'completed' AND completed_at IS NOT NULL") },
           class_name: "Claim"
  has_many :credential_assignments
  has_many :credit_transactions
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
    payments.sum(:amount)
  end

  def inconsistent_credits?
    trans = credit_transactions.status_ok.not_record_credit
    credits.to_f != trans.sum(:credits) || refundable_credits.to_f != trans.sum(:credits_refundable)
  end

  def purchases
    atts = %w( id name catalogable_type catalogable_id ).map { |k| "catalog_items.#{k}" }.join(", ")
    customer_orders.joins(:catalog_item)
                   .select("sum(customer_orders.amount) as total_amount, #{atts}")
                   .group(atts)
  end

  def infinite_entitlements_purchased
    single = customer_orders.includes(catalog_item: :catalogable).select do |customer_order|
      customer_order.catalog_item.catalogable&.entitlement&.infinite?
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
