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

  def company_event_agreements
    CompanyEventAgreement.where(event: @event)
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

  def point_of_sale_stations
    Station.joins(:station_type)
      .where(event: @event, station_types: { name: Station::POINT_OF_SALE_STATIONS })
  end

  def products
    Product.where(event: @event)
  end

  def stations
    Station.where(event: @event)
  end

  def sale_stations
    Station.joins(:station_type)
      .where(event: @event, station_types: { name: Station::SALE_STATIONS })
  end

  def topup_stations
    @event.stations.includes(:station_type).where(station_types: { name: Station::TOPUP_STATIONS })
  end

  def station_catalog_items
    StationCatalogItem.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def station_products
    StationProduct.joins(:product).where(products: { event_id: @event.id })
  end

  def topup_credits
    TopupCredit.joins(credit: :catalog_item).where("catalog_items.event_id = ?", @event.id)
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
