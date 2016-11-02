class Refund < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :claim

  # Validations
  validates :claim, :amount, presence: true

  # Scopes
  scope :query_for_csv, lambda { |event|
    joins(claim: { profile: :customer })
      .select("refunds.id, refunds.amount, refunds.currency, refunds.operation_type, refunds.message,
               refunds.gateway_transaction_number as transaction_number, refunds.payment_solution,
               claims.number as claim_number, customers.email, customers.first_name, customers.last_name,
               refunds.created_at")
      .where(profiles: { event_id: event.id })
  }
end
