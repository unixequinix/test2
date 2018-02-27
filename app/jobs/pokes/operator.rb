class Pokes::Operator < Pokes::Base
  TRIGGERS = %w[record_operator_permission].freeze

  queue_as :medium_low

  def perform(t)
    t.customer.update! operator: true
  end
end
