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
    event_management_stations
    default_event_parameters
    default_event_translations
    change_hardcoded_gtag_keys
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
                    privacy_policy: data["privacy_policy"],
                    terms_of_use: data["terms_of_use"],
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

  # TODO: This is a completely shit, but it's what we have. Clown fiesta.
  def change_hardcoded_gtag_keys
    parameters = @event.event_parameters.includes(:parameter)

    parameters.find_by(parameters: { category: "gtag", group: "ultralight_ev1", name: "ultralight_ev1_private_key" })
              .update!(value: SecureRandom.hex(16))

    parameters.find_by(parameters: { category: "gtag", group: "ultralight_c", name: "ultralight_c_private_key" })
              .update!(value: SecureRandom.hex(16))

    parameters.find_by(parameters: { category: "gtag", group: "mifare_classic", name: "mifare_classic_public_key" })
              .update!(value: SecureRandom.hex(6))

    parameters.find_by(parameters: { category: "gtag", group: "mifare_classic", name: "mifare_classic_private_key_a" })
              .update!(value: SecureRandom.hex(6))

    parameters.find_by(parameters: { category: "gtag", group: "mifare_classic", name: "mifare_classic_private_key_b" })
              .update!(value: SecureRandom.hex(6))
  end

  def customer_portal_station
    category = "customer_portal"
    station = @event.stations.create! name: category.humanize, category: category, group: "access"
    credit = @event.credits.standard.catalog_item
    station.station_catalog_items.create(catalog_item: credit, price: 1)
  end

  def customer_service_stations
    @event.stations.create! name: "CS Topup/Refund", category: "cs_topup_refund", group: "event_management"
    @event.stations.create! name: "CS Accreditation", category: "cs_accreditation", group: "event_management"
    @event.stations.create! name: "Glownet Food", category: "hospitality_top_up", group: "event_management"
  end

  def tocuhpoint_station
    @event.stations.create! name: "Touchpoint", category: "touchpoint", group: "touchpoint"
  end

  def event_management_stations
    @event.stations.create! name: "Operator Permissions", category: "operator_permissions", group: "event_management"
    @event.stations.create! name: "Gtag Recycler", category: "gtag_recycler", group: "glownet"
  end
end
