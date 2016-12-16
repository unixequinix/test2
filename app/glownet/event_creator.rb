class EventCreator
  attr_reader :event

  def initialize(params)
    @params = params
    @event = Event.none
  end

  def save
    I18n.locale = "en"
    @event = Event.new(default_settings.merge(@params))
    return unless @event.save
    @event.create_credit!(value: 1, name: "CRD", step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0)
    UserFlag.create!(event_id: @event.id, name: "alcohol_forbidden", step: 1)

    category = "customer_portal"
    station = @event.stations.create! name: category.humanize, category: category, group: "access"
    station.station_catalog_items.create(catalog_item: @event.credit, price: 1)
    @event.stations.create! name: "CS Topup/Refund", category: "cs_topup_refund", group: "event_management"
    @event.stations.create! name: "CS Accreditation", category: "cs_accreditation", group: "event_management"
    @event.stations.create! name: "Glownet Food", category: "hospitality_top_up", group: "event_management"
    @event.stations.create! name: "Touchpoint", category: "touchpoint", group: "touchpoint"
    @event.stations.create! name: "Operator Permissions", category: "operator_permissions", group: "event_management"
    @event.stations.create! name: "Gtag Recycler", category: "gtag_recycler", group: "glownet"
    @event
  end

  def default_settings
    {
      device_settings: YAML.load_file(Rails.root.join('config', 'glownet', 'device_settings.yml')),
      gtag_settings: YAML.load(ERB.new(File.read("#{Rails.root}/config/glownet/gtag_settings.yml")).result),
      gtag_name: "wristband",
      registration_settings: { phone: false, address: false, city: false, country: false, postcode: false, gender: false, birthdate: false, agreed_event_condition: false, receive_communications: false, receive_communications_two: false } # rubocop:disable Metrics/LineLength
    }
  end
end
