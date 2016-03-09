class Multitenancy::ApiFetcher
  def initialize(event)
    @event = event
    @pagination_enabled = @event.get_parameter("device", "general", "enable_api_pagination")
    @per_page = @event.get_parameter("device", "general", "api_records_per_page")
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

  def customer_event_profiles
    CustomerEventProfile.includes(:customer, :credential_assignments, :orders).where(event: @event)
  end

  def event_parameters
    EventParameter.where(event: @event)
  end

  def device_general_parameters
    EventParameter.where(event: @event, parameters: { category: "device", group: "general" })
      .includes(:parameter)
  end

  def gtags
    Gtag.includes(:credential_assignments, :company_ticket_type, :purchaser).where(event: @event)
  end

  def banned_gtags
    Gtag.banned.where(event: @event)
  end

  def products
    Product.includes(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def packs
    Pack.includes(:catalog_item, pack_catalog_items: :catalog_item)
      .where(catalog_items: { event_id: @event.id })
  end

  def stations
    StationGroup.joins(:station_types, station_types: :stations).all
  end

  def sale_stations
    Station.joins(:station_type)
      .where(event: @event, station_types: { name: Station::SALE_STATIONS })
  end

  def station_catalog_items
    StationCatalogItem.joins(:catalog_item).where(catalog_items: { event_id: @event.id })
  end

  def tickets
    Ticket.joins(:credential_assignments, :company_ticket_type)
      .joins("FULL OUTER JOIN purchasers
              ON purchasers.credentiable_id = tickets.id
              AND purchasers.credentiable_type = 'Ticket'
              AND purchasers.deleted_at IS NULL")
      .select("tickets.id, tickets.code as reference, tickets.credential_redeemed,
               tickets.company_ticket_type_id, tickets.updated_at,
               credential_assignments.customer_event_profile_id as customer_id,
               company_ticket_types.credential_type_id as credential_type_id ,
               purchasers.first_name as purchaser_first_name,
               purchasers.last_name as purchaser_last_name,
               purchasers.email as purchaser_email")
      .where(event: @event)
  end

  def banned_tickets
    Ticket.banned.where(event: @event)
  end

  def vouchers
    Voucher.includes(:catalog_item, :entitlement).where(catalog_items: { event_id: @event.id })
  end
end
