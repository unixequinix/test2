class Pokes::Operator < Pokes::Base
  TRIGGERS = %w[record_operator_permission].freeze

  queue_as :medium_low

  def perform(transaction)
    transaction.customer.update! operator: true
    transaction.gtag&.update! operator: true
  end
end
