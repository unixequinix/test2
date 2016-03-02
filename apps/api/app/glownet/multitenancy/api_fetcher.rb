class Multitenancy::ApiFetcher
  def initialize(event)
    @event = event
  end

  def accesses
    Access.joins(:catalog_item, :entitlement).where(catalog_items: { event_id: @event.id })
  end

  def company_ticket_types
    CompanyTicketType.includes(:credential_type, company_event_agreement: :company)
                     .where(event: @event)
  end

  def credential_types
    CredentialType.includes(:catalog_item).where(catalog_items: { event_id: @event.id })
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
    Pack.includes(:catalog_item, pack_catalog_items: :catalog_item)
    .where(catalog_items: { event_id: @event.id })
  end

  def stations
    Station.where(event: @event)
  end

  def sale_stations
    Station.joins(:station_type)
      .where(event: @event, station_types: { name: Station::SALE_STATIONS })
  end

  def station_catalog_items
    StationCatalogItem.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def tickets
    Ticket.includes(:credential_assignments, :company_ticket_type).where(event: @event)
  end

  def vouchers
    Voucher.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end
end
