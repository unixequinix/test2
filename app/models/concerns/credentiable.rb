module Credentiable
  extend ActiveSupport::Concern

  included do
    belongs_to :event
    belongs_to :customer, optional: true

    has_many :transactions, dependent: :restrict_with_error
  end

  def customer_not_anonymous?
    customer && !customer.anonymous?
  end

  def validate_assignation
    errors.add(:reference, I18n.t("credentials.not_found", item: I18n.t("credentials.name"))) if new_record?
    errors.add(:reference, I18n.t("credentials.blacklisted", item: I18n.t("credentials.name"))) if banned?
    errors.empty?
  end

  def ban
    update_attribute(:banned, true)
  end

  def unban
    update_attribute(:banned, false)
  end

  def assign_customer(new_customer, operator, origin = :portal)
    update!(customer: new_customer)
    new_customer.touch
    write_assignation_transaction("assigned", operator, origin)
  end

  def unassign_customer(operator = nil, origin = :portal)
    customer&.touch
    write_assignation_transaction("unassigned", operator, origin)
    update!(customer: nil)
  end

  def write_assignation_transaction(action, operator, origin = :portal)
    action = "#{model_name.element}_#{action}"
    CredentialTransaction.write!(event, action, origin, customer, operator, assignation_atts)
  end
end
