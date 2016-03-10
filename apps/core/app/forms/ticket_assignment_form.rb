class TicketAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :code, String

  validates_presence_of :code

  def save(ticket_fetcher, current_customer_event_profile, current_event)
    ticket = ticket_fetcher.find_by(code: code.strip)
    companies = CompanyTicketType.companies(current_event).join(", ")
    if ticket.nil?
      errors.add(:ticket_assignment, I18n.t("alerts.admissions", companies: companies)) && return
    end

    errors.add(:ticket_assignment, full_messages.join(". ")) && return unless valid?
    persist!(ticket, current_customer_event_profile, CustomerCreditTicketCreator.new, CustomerOrderTicketCreator.new)
  end

  private

  def persist!(ticket, customer_event_profile, customer_credit_creator, customer_order_creator)
    customer_event_profile.save
    customer_event_profile.credential_assignments.create(credentiable: ticket)
    customer_credit_creator.assign(ticket) if ticket.credits.present?
    customer_order_creator.save(ticket)
    customer_event_profile
  end
end
