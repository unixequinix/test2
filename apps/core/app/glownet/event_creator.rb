class EventCreator
  attr_reader :event

  def initialize(params)
    @params = params
    @event = Event.none
  end

  def save
    @event = Event.new(@params)
    return unless @event.save
    standard_credit
    customer_portal_station
    customer_service_stations
    tocuhpoint_station
    default_event_parameters
    default_event_translations
    @event
  end

  def default_event_parameters
    Seeder::SeedLoader.load_default_event_parameters(@event)
  end

  def default_event_translations
    YAML.load_file(Rails.root.join("db", "seeds", "default_event_translations.yml")).each do |data|
      I18n.locale = data["locale"]
      @event.update(info: data["info"],
                    disclaimer: data["disclaimer"],
                    refund_success_message: data["refund_success_message"],
                    mass_email_claim_notification: data["mass_email_claim_notification"],
                    gtag_assignation_notification: data["gtag_assignation_notification"],
                    gtag_form_disclaimer: data["gtag_form_disclaimer"],
                    gtag_name: data["gtag_name"])
    end
  end

  def standard_credit
    YAML.load_file(Rails.root.join("db", "seeds", "standard_credits.yml")).each do |data|
      Credit.create!(standard: data["standard"],
                     currency: data["currency"],
                     value: data["value"],
                     catalog_item_attributes: { event_id: @event.id,
                                                name: data["name"],
                                                step: data["step"],
                                                min_purchasable: data["min_purchasable"],
                                                max_purchasable: data["max_purchasable"],
                                                initial_amount: data["initial_amount"] })
    end
  end

  def customer_portal_station
    station = Station.create!(event: @event, name: "Customer Portal",
                              category: "customer_portal", group: "access")

    credit = @event.credits.standard.catalog_item
    station.station_catalog_items.create(catalog_item: credit, price: 1)
  end

  def customer_service_stations
    Station.create!(event: @event, name: "CS Topup/Refund",
                    category: "cs_topup_refund", group: "event_management")

    Station.create!(event: @event, name: "CS Gtag Balance Fix",
                    category: "cs_gtag_balance_fix", group: "event_management")

    Station.create!(event: @event, name: "CS Accreditation",
                    category: "cs_accreditation", group: "event_management")
  end

  def tocuhpoint_station
    Station.create!(event: @event, name: "Touchpoint", category: "touchpoint", group: "touchpoint")
  end
end
