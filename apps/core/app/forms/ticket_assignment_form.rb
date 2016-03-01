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
    persist!(ticket, current_customer_event_profile)
  end

  private

  def persist!(ticket, customer_event_profile)
    customer_event_profile.save
    customer_event_profile.credential_assignments.create(credentiable: ticket)
    CustomerCreditCreator.new(customer_event_profile: customer_event_profile,
                              transaction_source: CustomerCredit::TICKET_ASSIGNMENT,
                              amount: ticket.credits,
                              payment_method: "none"
                             ).save if ticket.credits.present?
    customer_event_profile
  end
end
