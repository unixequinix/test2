namespace :glownet do
  desc "Creates a basic event"
  task vicentest: :environment do
    @event = EventCreator.new({
      name: "Vicentest v#{Time.zone.now.to_s(:number)}",
      location: "Glownet",
      start_date: DateTime.now,
      end_date: DateTime.now + 4.days,
      description: "Keep calm and keep testing!",
      support_email: "support@glownet.com",
      currency: "EUR",
      host_country: "USA",
      gtag_name: "Wristband",
      token_symbol: "t",
      features: 495,
      refund_services: 3,
      payment_services: 1
    }).save

    data = ["device_settings", "customers", "accesses", "packs", "products", "ticket_types", "tickets",
            "checkin_stations", "box_office_stations", "access_control_stations", "staff_accreditation_stations",
            "vendor_stations", "bar_stations", "topup_stations"]

    data.each do |d|
      puts "+ Creating #{d.humanize}"
      eval("create_#{d}")
    end

    puts "-------------------------------------------"
    puts "Event name: '#{@event.name}'"
  end

  def create_device_settings
    @event.event_parameters
          .includes(:parameter)
          .find_by(parameters: { category: "device", group: "general", name: "private_zone_password" })
          .update!(value: "a")
  end

  def create_customers
    Customer.create!({
      event_id: @event.id,
      first_name: "Vicentest",
      last_name: "Test",
      email: "test@test.com",
      agreed_on_registration: true,
      phone: "512 2301 440",
      country: "ES",
      gender: "male",
      birthdate: Date.new(rand(1900..2000), rand(1..12), rand(1..28)),
      postcode: "28012",
      agreed_event_condition: true,
      encrypted_password: Authentication::Encryptor.digest("test")
    })
  end

  def create_accesses
    accesses = [
      { name: "Day", mode: "permanent_strict", credential: true},
      { name: "Night", mode: "counter", credential: false},
      { name: "VIP", mode: "permanent", credential: false},
      { name: "Camping", mode: "permanent", credential: false},
      { name: "Staff", mode: "permanent", credential: false},
      { name: "Glownet Staff", mode: "permanent", credential: false}
    ]

    accesses.each do |access|
      a = Access.create!(catalog_item_attributes: {
                           event_id: @event.id,
                           name: access[:name],
                           description: "@channel is awesome :)",
                           step: 1,
                           min_purchasable: 0,
                           max_purchasable: 1,
                           initial_amount: 0
                         },
                         entitlement_attributes: { event_id: @event.id, mode: access[:mode], })

      a.catalog_item.create_credential_type if access[:credential]
    end
  end

  def create_packs
    packs = [
      { name: "Day + Night",
        catalog_items: [{ name: "Day", amount: 1 }, { name: "Night", amount: 1 }],
        credential: true },
      { name: "Day + VIP",
        catalog_items: [{ name: "Day", amount: 1 }, { name: "VIP", amount: 1 }],
        credential: true },
      { name: "Night + VIP",
        catalog_items: [{ name: "Night", amount: 1 }, { name: "VIP", amount: 1 }],
        credential: true },
      { name: "Day + Camping",
        catalog_items: [{ name: "Day", amount: 1 }, { name: "Camping", amount: 1 }],
        credential: true },
      { name: "Day + Night + VIP",
        catalog_items: [{ name: "Day", amount: 1 }, { name: "Night", amount: 1 }, { name: "VIP", amount: 1 }],
        credential: true },
      { name: "50e + 15e Free Pack",
        catalog_items: [{ name: "Standard credit", amount: 65 }],
        credential: false }
    ]

    packs.each do |pack|
      p = Pack.new(catalog_item_attributes: { event_id: @event.id,
                                              name: pack[:name],
                                              description: "@channel is awesome :)",
                                              step: 1,
                                              min_purchasable: 0,
                                              max_purchasable: 1,
                                              initial_amount: 0 })
     pack[:catalog_items].each do |ci|
       item = @event.catalog_items.find_by(name: ci[:name], event: @event)
       p.pack_catalog_items.build(catalog_item: item, amount: ci[:amount] ).save
     end

     p.save! # Because association validation in pack model

     p.catalog_item.create_credential_type if pack[:credential]
    end
  end

  def create_products
    10.times do |index|
      @event.products.create!(name: "Product #{index + 1}",
                              description: "@channel is awesome :)",
                              is_alcohol: [true, false].sample)
    end

    10.times do |index|
      @event.products.create!(name: "Market #{index + 1}",
                              description: "@channel is awesome :)",
                              is_alcohol: [true, false].sample)
    end
  end

  def create_ticket_types
    company = Company.find_or_create_by(name: "Glownet")
    agreement = CompanyEventAgreement.create!(event: @event, company: company)
    credential_types = CredentialType.joins(:catalog_item).where(catalog_items: { event_id: @event.id })

    credential_types.each do |credential_type|
      @event.company_ticket_types.create!(company_event_agreement: agreement,
                                          credential_type_id: credential_type.id,
                                          company_code: Time.zone.now.to_i + rand(10000),
                                          name: credential_type.catalog_item.name)
    end
  end

  def create_tickets
    ticket_types = CompanyTicketType.where(event: @event)

    ticket_types.each do |tt|
      5.times do
        @event.tickets.create!(company_ticket_type: tt, code: SecureRandom.hex(16).upcase, credential_redeemed: false)
      end
    end
  end

  def create_checkin_stations
    @event.stations.create!(name: "Checkin", group: "access", category: "check_in")
    @event.stations.create!(name: "Dummy Checkin", group: "access", category: "ticket_validation")
  end

  def create_access_control_stations
    ­accesses = [
      { name: "Day", direction: 1 },
      { name: "Day", direction: -1 },
      { name: "VIP", direction: 1 },
      { name: "Camping", direction: 1},
      { name: "Night", direction: 1 }]

    station = @event.stations.create!(name: "Access Control", group: "access", category: "access_control")

    ­accesses.each do |access|
      item = CatalogItem.find_by(name: access[:name], event: @event)
      station.access_control_gates.new(direction: access[:direction],
                                       access: item.catalogable,
                                       station_parameter_attributes: { station_id: station.id }).save
    end
  end

  def create_box_office_stations
    bo = @event.stations.create!(name: "Box office", group: "access", category: "box_office")

    items = [
      { name: "Day", price: 20 },
      { name: "Day + Night", price: 40 },
      { name: "Day + VIP", price: 30 },
      { name: "Night + VIP", price: 30 },
      { name: "Day + Camping", price: 30 },
      { name: "Day + Night + VIP", price: 50 },
      { name: "50e + 15e Free Pack", price: 50 }
    ]

    items.each do |i|
      item = CatalogItem.find_by(name: i[:name], event: @event)
      bo.station_catalog_items.new(price: i[:price],
                                   catalog_item: item,
                                   station_parameter_attributes: { station_id: bo.id }).save
    end
  end

  def create_staff_accreditation_stations
    station = @event.stations.create!(name: "Staff Accreditation", group: "access", category: "staff_accreditation")
    items = ["Staff", "Glownet Staff"]

    items.each do |item_name|
      item = CatalogItem.find_by(name: item_name, event: @event)
      station.station_catalog_items.new(price: 0,
                                        catalog_item: item,
                                        station_parameter_attributes: { station_id: station.id }).save
    end
  end

  def create_vendor_stations
    products = [
      { name: "Market 1", price: 0.01 },
      { name: "Market 2", price: 0.05 },
      { name: "Market 3", price: 0.1 },
      { name: "Market 4", price: 0.5 },
      { name: "Market 5", price: 1 },
      { name: "Market 6", price: 5 },
      { name: "Market 7", price: 10 },
      { name: "Market 8", price: 20 },
      { name: "Market 9", price: 25 },
      { name: "Market 10", price: 50 }
    ]
    station = @event.stations.create!(name: "MARKET 1", group: "monetary", category: "vendor")

    products.each do |p|
      product = Product.find_by(name: p[:name], event: @event)
      station.station_products.new(price: p[:price],
                                   product: product,
                                   station_parameter_attributes: { station_id: station.id }).save
    end
  end

  def create_bar_stations
    products = [
      { name: "Product 1", price: 1 },
      { name: "Product 2", price: 2 },
      { name: "Product 3", price: 3 },
      { name: "Product 4", price: 4 },
      { name: "Product 5", price: 5 },
      { name: "Product 6", price: 6 },
      { name: "Product 7", price: 7 },
      { name: "Product 8", price: 8 },
      { name: "Product 9", price: 9 },
      { name: "Product 10", price: 10 }
    ]
    station = @event.stations.create!(name: "BAR 1", group: "monetary", category: "bar")

    products.each do |p|
      product = Product.find_by(name: p[:name], event: @event)
      station.station_products.new(price: p[:price],
                                   product: product,
                                   station_parameter_attributes: { station_id: station.id }).save
    end
  end

  def create_topup_stations
    @event.stations.create!(name: "Topup/Refund", group: "monetary", category: "top_up_refund")
  end
end
