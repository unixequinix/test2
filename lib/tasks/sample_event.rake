namespace :glownet do
  desc "Creates a basic event"
  task sample_event: :environment do
    @event = Event.create({
      name: "Event v#{Time.zone.now.to_s(:number)}",
      start_date: DateTime.now,
      end_date: DateTime.now + 4.days,
      support_email: "support@glownet.com",
      currency: "EUR",
      token_symbol: "t"
    })

    UserFlag.create!(event_id: @event.id, name: "alcohol_forbidden", step: 1)
    @event.create_credit!(value: 1, name: "CRD", step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0)
    station = @event.stations.create! name: "Customer Portal", category: "customer_portal", group: "access"
    station.station_catalog_items.create(catalog_item: @event.credit, price: 1)
    @event.stations.create! name: "CS Topup/Refund", category: "cs_topup_refund", group: "event_management"
    @event.stations.create! name: "CS Accreditation", category: "cs_accreditation", group: "event_management"
    @event.stations.create! name: "Glownet Food", category: "hospitality_top_up", group: "event_management"
    @event.stations.create! name: "Touchpoint", category: "touchpoint", group: "touchpoint"
    @event.stations.create! name: "Operator Permissions", category: "operator_permissions", group: "event_management"
    @event.stations.create! name: "Gtag Recycler", category: "gtag_recycler", group: "glownet"

    data = ["customers", "accesses", "packs", "products", "ticket_types", "tickets",
            "checkin_stations", "box_office_stations", "access_control_stations", "staff_accreditation_stations",
            "vendor_stations", "bar_stations", "topup_stations"]

    data.each do |d|
      puts "+ Creating #{d.humanize}"
      eval("create_#{d}")
    end

    puts "-------------------------------------------"
    puts "Event name: '#{@event.name}'"
    puts "https://#{Rails.env}.glownet.com/admins/events/#{@event.slug}"
  end

  def create_customers
    @event.customers.create!(first_name: "Vicentest",
                             last_name: "Test",
                             email: "test@test.com",
                             agreed_on_registration: true,
                             phone: "512 2301 440",
                             country: "ES",
                             gender: "male",
                             birthdate: Date.new(rand(1900..2000), rand(1..12), rand(1..28)),
                             postcode: "28012",
                             agreed_event_condition: true,
                             password: "test",
                             password_confirmation: "test")
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
      @event.accesses.create!(name: access[:name],
                              step: 1,
                              min_purchasable: 0,
                              max_purchasable: 1,
                              initial_amount: 0,
                              entitlement_attributes: { event_id: @event.id, mode: access[:mode], })
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
        catalog_items: [{ name: "CRD", amount: 65 }],
        credential: false }
    ]

    packs.each do |pack|
      p = Pack.new(event_id: @event.id,
                   name: pack[:name],
                   step: 1,
                   min_purchasable: 0,
                   max_purchasable: 1,
                   initial_amount: 0)
     pack[:catalog_items].each do |ci|
       item = @event.catalog_items.find_by_name(ci[:name])
       p.pack_catalog_items.build(catalog_item: item, amount: ci[:amount] ).save
     end

     p.save! # Because association validation in pack model
    end
  end

  def create_products
    10.times do |index|
      @event.products.create!(name: "Product #{index + 1}", description: "blah blah", is_alcohol: [true, false].sample)
    end

    10.times do |index|
      @event.products.create!(name: "Market #{index + 1}", description: "blah blah", is_alcohol: [true, false].sample)
    end
  end

  def create_ticket_types
    company = Company.find_or_create_by(name: "Glownet")
    agreement = CompanyEventAgreement.create!(event: @event, company: company)

    @event.accesses.each do |catalog_item|
      @event.ticket_types.create!(company_event_agreement: agreement,
                                  catalog_item: catalog_item,
                                  company_code: Time.zone.now.to_i + rand(10000),
                                  name: catalog_item.name)
    end
  end

  def create_tickets
    ticket_types = TicketType.where(event: @event)

    ticket_types.each do |tt|
      5.times do
        @event.tickets.create!(ticket_type: tt, code: SecureRandom.hex(16).upcase, redeemed: false)
      end
    end
  end

  def create_checkin_stations
    @event.stations.create!(name: "Checkin", group: "access", category: "check_in")
    @event.stations.create!(name: "Dummy Checkin", group: "access", category: "ticket_validation")
  end

  def create_access_control_stations
    accesses = [{ name: "Day", direction: 1 }, { name: "Day", direction: -1 }]
    station = @event.stations.create!(name: "Access Control", group: "access", category: "access_control")

    accesses.each do |access|
      item = CatalogItem.find_by(name: access[:name], event: @event)
      station.access_control_gates.create(direction: access[:direction], access: item, station: station)
    end
  end

  def create_box_office_stations
    station = @event.stations.create!(name: "Box office", group: "access", category: "box_office")

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
      station.station_catalog_items.create(price: i[:price], catalog_item: item, station: station)
    end
  end

  def create_staff_accreditation_stations
    station = @event.stations.create!(name: "Staff Accreditation", group: "access", category: "staff_accreditation")
    items = ["Staff", "Glownet Staff"]

    items.each do |item_name|
      item = CatalogItem.find_by(name: item_name, event: @event)
      station.station_catalog_items.create(price: 0, catalog_item: item, station: station)
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
      station.station_products.create(price: p[:price], product: product, station: station)
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
      station.station_products.create(price: p[:price], product: product, station: station )
    end
  end

  def create_topup_stations
    @event.stations.create!(name: "Topup/Refund", group: "monetary", category: "top_up_refund")
  end
end
