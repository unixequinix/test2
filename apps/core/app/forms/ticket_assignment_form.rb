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
    item_in_ticket(ticket)
    return(item_in_ticket.catalogable.entitlement.infinite? &&
      credential_already_owned?(ticket, current_profile)) if %w(Access Voucher)
      .include?(item_in_ticket.catalogable_type)
    false
  end

  def credential_already_owned?(item_in_ticket, current_profile)
    items_owned = CatalogItem.where(id: current_profile.customer_orders.map(&:catalog_item_id))
    items_owned.include? item_in_ticket
  end

  def owns_all_items?(item_in_ticket, current_profile)
    items_owned = CatalogItem.where(id: current_profile.customer_orders.map(&:catalog_item_id))
    (Array(item_in_ticket) - items_owned).empty?
  end

  def item_in_ticket(ticket)
    ticket.credential_type_item.catalogable_type == "Pack" ?
      ticket.credential_type_item.open_all :
      ticket.credential_type_item
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
