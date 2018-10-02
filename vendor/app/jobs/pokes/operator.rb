class Pokes::Operator < Pokes::Base
  TRIGGERS = %w[record_operator_permission].freeze

  queue_as :low

  def perform(transaction)
    customer = transaction.customer
    customer.operator = true
    customer.save(validate: false)

    transaction.gtag&.update! operator: true
  end
end
