module Credentiable
  extend ActiveSupport::Concern

  included do
    belongs_to :event, counter_cache: true
    belongs_to :customer, optional: true, touch: true

    has_many :transactions, dependent: :restrict_with_error
    has_many :pokes_as_credential, as: :credential, class_name: "Poke", dependent: :restrict_with_error # rubocop:disable Rails/InverseOf
  end

  def purchaser_full_name
    "#{try(:purchaser_first_name)} #{try(:purchaser_last_name)}"
  end

  def credential_type
    self.class.to_s.downcase
  end

  def customer_not_anonymous?
    customer.present? && !customer.anonymous?
  end

  def validate_assignation
    errors.add(:reference, I18n.t("credentials.not_found", item: I18n.t("credentials.name"))) if new_record?
    errors.add(:reference, I18n.t("credentials.already_assigned", item: I18n.t("credentials.name"))) if customer_not_anonymous?
    errors.add(:reference, I18n.t("credentials.blacklisted", item: I18n.t("credentials.name"))) if banned?
    errors.empty?
  end

  def ban
    update_attribute(:banned, true)
  end

  def unban
    update_attribute(:banned, false)
  end

  def assign_customer(new_customer, _operator = nil)
    if customer.present?
      Customer.claim(event, new_customer, customer)
      reload # this is necessary because the customer is updated in the background
    else
      update!(customer: new_customer)
    end
    new_customer.touch
  end

  def unassign_customer(_operator = nil)
    customer&.touch
    update!(customer: nil)
  end
end
