class TicketAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :code, String

  validates_presence_of :code

  def save(ticket_fetcher, current_profile, current_event)
    ticket = ticket_fetcher.find_by(code: code.strip)
    companies = CompanyTicketType.companies(current_event).join(", ")

    return unless valid_ticket?(ticket, companies, current_profile)

    errors.add(:ticket_assignment, full_messages.join(". ")) && return unless valid?
    persist!(ticket,
             current_profile,
             CustomerCreditTicketCreator.new,
             CustomerOrderTicketCreator.new)
  end

  private

  def persist!(ticket, customer_event_profile, customer_credit_creator, customer_order_creator)
    customer_event_profile.save
    customer_event_profile.credential_assignments.create(credentiable: ticket)
    customer_credit_creator.assign(ticket) if ticket.credits.present?
    customer_order_creator.save(ticket)
    customer_event_profile
  end

  def already_assigned?(ticket)
    ticket.assigned_ticket_credential.present?
  end

  def infinite_credential_already_owned?(ticket, current_profile)
    all_infinites?(ticket) && owns_all_items?(ticket, current_profile)
  end

  def all_infinites?(ticket)
    items_in_ticket(ticket).all? { |item| item.catalogable.try(:entitlement).try(:infinite?) }
  end

  def items_in_ticket(ticket)
    credential_type_item = ticket.credential_type_item
    if credential_type_item.catalogable_type == "Pack"
      credential_type_item.catalogable.open_all.map { |i| CatalogItem.find(i.catalog_item_id) }
    else
      Array(credential_type_item)
    end
  end

  def owns_all_items?(ticket, current_profile)
    items_owned = CatalogItem.where(id: current_profile.customer_orders.map(&:catalog_item_id))
    (items_in_ticket(ticket) - items_owned).empty?
  end

  private

  def valid_ticket?(ticket, companies, current_profile)
    errors.add(:ticket_assignment, I18n.t("alerts.admissions", companies: companies)) &&
      return if ticket.nil?
    errors.add(:ticket_assignment, I18n.t("alerts.ticket_already_assigned")) &&
      return if already_assigned?(ticket)
    errors.add(:ticket_assignment, I18n.t("alerts.credential_already_assigned")) &&
      return if infinite_credential_already_owned?(ticket, current_profile)
    true
  end


end


