class TicketAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :code, String

  validates_presence_of :code

  def save(ticket_fetcher, current_customer_event_profile, current_event)
    ticket = ticket_fetcher.find_by(code: code.strip)
    companies = CompanyTicketType.companies(current_event).join(", ")
    binding.pry
    if ticket.nil?
      errors.add(:ticket_assignment, I18n.t("alerts.admissions", companies: companies)) && return
    end

    binding.pry
    errors.add(:ticket_assignment, full_messages.join(". ")) && return unless valid?
    persist!(ticket, current_customer_event_profile)
  end

  private

  def persist!(ticket, profile)
    profile.save
    profile.credential_assignments.create(credentiable: ticket)
    binding.pry
    CreditLog.create(
      customer_event_profile: profile,
      transaction_type: CreditLog::TICKET_ASSIGNMENT,
      amount: ticket.preevent_product_items_credits.sum(:amount)
    ) if ticket.preevent_product_items_credits.present?
  end
end
