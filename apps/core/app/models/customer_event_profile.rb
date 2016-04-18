# == Schema Information
#
# Table name: customer_event_profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#  deleted_at  :datetime
#

class CustomerEventProfile < ActiveRecord::Base # rubocop:disable ClassLength
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
  # TODO: check with current_balance method for duplication
  has_many :customer_credits do
    def current
      order("created_in_origin_at DESC").first
    end
  end

  has_many :completed_claims, -> { where("aasm_state = 'completed' AND completed_at != NULL") },
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
  has_many :gtag_assignment,
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
  has_one :banned_customer_event_profile
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
  scope :banned, -> { joins(:banned_customer_event_profile) }

  def customer
    Customer.unscoped { super }
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
    customer_credits.map do |customer_credit|
      customer_credit.credit_value * customer_credit.refundable_amount
    end.sum
  end

  def online_refundable_money_amount
    payments.sum(:amount)
  end

  def update_balance_after_refund(refund)
    neg = (refund.amount * -1)
    params = {
      amount: neg, refundable_amount: neg, credit_value: event.standard_credit_price,
      payment_method: refund.payment_solution, transaction_origin: "refund"
    }
    customer_credits.create!(params)
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
    single_entitlements = customer_orders.select do |customer_order|
      customer_order.catalog_item.catalogable.try(:entitlement).try(:infinite)
    end.map(&:catalog_item_id)

    pack_entitlements = CatalogItem.where(
      catalogable_id: Pack.joins(:catalog_items_included)
                          .where(catalog_items: { id: single_entitlements }),
      catalogable_type: "Pack")
                        .pluck(:id)

    single_entitlements + pack_entitlements
  end

  def sorted_purchases(**params)
    Sorters::PurchasesSorter.new(purchases).sort(params)
  end

  def gateway_customer(gateway)
    payment_gateway_customers.find_by(gateway_type: gateway)
  end
end
