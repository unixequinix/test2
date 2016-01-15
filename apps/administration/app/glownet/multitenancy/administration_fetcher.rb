# TODO: - Check Pundit Scopes instead of fetchers
class Multitenancy::AdministrationFetcher
  def initialize(event)
    @event = event
  end

  def company_ticket_types
    CompanyTicketType.where(event_id: @event.id)
  end

  def credential_types
    CredentialType.joins(:preevent_item).where(preevent_items: { event_id: @event.id })
  end

  def credits
    Credit.joins(:preevent_item).where(preevent_items: { event_id: @event.id })
  end

  def customers
    Customer.where(event_id: @event.id)
  end

  def customer_event_profiles
    CustomerEventProfile.where(event_id: @event.id)
  end

  def event_parameters
    EventParameter.where(event_id: @event.id)
  end

  def gtags
    Gtag.where(event: @event)
  end

  def preevent_items
    PreeventItem.where(event_id: @event.id)
  end

  def preevent_products
    PreeventProduct.where(event_id: @event.id)
  end

  def tickets
    Ticket.where(event: @event)
  end

  def vouchers
    Voucher.joins(:preevent_item).where(preevent_items: { event_id: @event.id })
  end

  private

  def admin?
    @user.is_admin?
  end

  def manager?
    @user.is_manager?
  end
end
