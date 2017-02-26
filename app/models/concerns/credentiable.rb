module Credentiable
  extend ActiveSupport::Concern

  included do
    belongs_to :event
    belongs_to :customer
    belongs_to :ticket_type

    has_many :transactions, dependent: :restrict_with_error
  end

  def ban
    update_attribute(:banned, true)
  end

  def unban
    update_attribute(:banned, false)
  end

  def assign_customer(new_customer, origin, operator)
    update!(customer: new_customer)
    new_customer.touch
    write_assignation_transaction("assigned", origin, operator)
  end

  def unassign_customer(origin, operator)
    customer&.touch
    write_assignation_transaction("unassigned", origin, operator)
    update!(customer: nil)
  end

  def write_assignation_transaction(action, origin, operator)
    action = "#{model_name.element}_#{action}"
    CredentialTransaction.write!(event, action, origin, customer, operator, assignation_atts)
  end
end
