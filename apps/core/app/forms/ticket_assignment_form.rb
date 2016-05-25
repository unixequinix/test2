class TicketAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :code, String
  validates_presence_of :code

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  def save(ticket_fetcher, current_profile, current_event)
    ticket = ticket_fetcher.find_by(code: code.strip)

    if ticket.blank?
      companies = CompanyTicketType.companies(current_event).to_sentence
      add_error("alerts.admissions", companies: companies) && return
    end

    t_type_owned = current_profile.active_assignments
                                  .map(&:credentiable)
                                  .map(&:company_ticket_type_id)
                                  .include?(ticket.company_ticket_type_id)

    cred_owned = if ticket.company_ticket_type.credential_type
                   items = open_pack(ticket)
                   infinites = items.all? { |item| item.catalogable.try(:entitlement)&.infinite? }
                   items_owned = current_profile.customer_orders.map(&:catalog_item)
                   same_items = (items - items_owned).empty?
                   infinites && same_items
                 end

    add_error("alerts.credential_already_assigned") && return if t_type_owned || cred_owned

    credential = ticket.assigned_ticket_credential
    add_error("alerts.ticket_already_assigned") && return if credential.present?
    add_error(full_messages.to_sentence) && return unless valid?

    current_profile.save
    current_profile.credential_assignments.create(credentiable: ticket)
    if ticket.company_ticket_type.credential_type
      CustomerCreditTicketCreator.new.assign(ticket) if ticket.credits.present?
      CustomerOrderTicketCreator.new.save(ticket)
    end

    current_profile
  end

  private

  def open_pack(ticket)
    c_item = ticket.credential_type_item
    c_item = c_item.catalogable.open_all.map(&:catalog_item) if c_item.catalogable_type == "Pack"
    [c_item].flatten
  end

  def add_error(text, atts = {})
    errors.add(:ticket_assignment, I18n.t(text, atts))
  end
end
