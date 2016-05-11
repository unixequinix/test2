class TicketAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :code, String

  validates_presence_of :code

  def save(ticket_fetcher, current_profile, current_event)
    ticket = ticket_fetcher.find_by(code: code.strip)

    add_error("alerts.ticket_doesnt_exist") && return if ticket.blank?
    companies = CompanyTicketType.companies(current_event).join(", ")

    return unless valid_ticket?(ticket, companies, current_profile)

    current_profile.save
    current_profile.credential_assignments.create(credentiable: ticket)
    CustomerCreditTicketCreator.new.assign(ticket) if ticket.credits.present?
    CustomerOrderTicketCreator.new.save(ticket)
    current_profile
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity
  def valid_ticket?(ticket, companies, current_profile)
    items = open_pack(ticket)
    infinites = items.all? { |item| item.catalogable.try(:entitlement)&.infinite? }
    items_owned = current_profile.customer_orders.map(&:catalog_item)

    add_error("alerts.admissions", companies: companies) if ticket.nil?
    add_error("alerts.ticket_already_assigned") if ticket.assigned_ticket_credential.present?
    add_error("alerts.credential_already_assigned") if infinites && (items - items_owned).empty?
    add_error(full_messages.to_sentence) unless valid?
    return true unless errors.any?
  end

  def open_pack(ticket)
    c_item = ticket.credential_type_item
    c_item = c_item.catalogable.open_all.map(&:catalog_item) if c_item.catalogable_type == "Pack"
    [c_item].flatten
  end

  def add_error(text, atts = {})
    errors.add(:ticket_assignment, I18n.t(text, atts))
  end
end
