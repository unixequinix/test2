# TODO: - Check Pundit Scopes instead of fetchers
class Multitenancy::AdministrationFetcher
  def initialize(event)
    @event = event
  end

  def accesses
    Access.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def catalog_items
    CatalogItem.where(event: @event)
  end

  def company_ticket_types
    CompanyTicketType.where(event: @event)
  end

  def companies
    Company.where(event: @event)
  end

  def credential_types
    CredentialType.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def credits
    Credit.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def customers
    Customer.where(event: @event)
  end

  def customer_event_profiles
    CustomerEventProfile.where(event: @event)
  end

  def event_parameters
    EventParameter.where(event: @event)
  end

  def device_general_parameters
    EventParameter.where(event: @event, parameters: { category: "device", group: "general" })
      .includes(:parameter)
  end

  def gtags
    Gtag.where(event: @event)
  end

  def packs
    Pack.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def stations
    Station.where(event: @event)
  end

  def sales_stations
    Station.joins(:station_type)
      .where(event: @event, station_types: { name: Station::SALES_STATIONS })
  end

  def tickets
    Ticket.where(event: @event)
  end

  def vouchers
    Voucher.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  private

  def admin?
    @user.is_admin?
  end

  def manager?
    @user.is_manager?
  end
end
