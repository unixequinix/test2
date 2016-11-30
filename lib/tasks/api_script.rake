namespace :glownet do
  desc "Creates a basic event"
  task api_script: :environment do
    event_common = { start_date: DateTime.now, end_date: DateTime.now + 4.days, location: "Spain", support_email: "support@glownet.com", currency: "EUR", host_country: "Spain", gtag_name: "Wristband", token_symbol: "t" }
    @event = EventCreator.new(event_common.merge({ name: "PreEvent #{Time.now.to_i}", aasm_state: "launched"})).save

    data = ["customers", "accesses", "packs", "products", "ticket_types", "tickets",
            "checkin_stations", "box_office_stations", "access_control_stations", "staff_accreditation_stations",
            "vendor_stations", "bar_stations", "topup_stations"]

    data.each do |d|
      puts "+ Creating #{d.humanize}"
      eval("add_#{d}")
    end

    puts "-------------------------------------------"
    puts "Event name: '#{@event.name}'"
    puts "https://#{Rails.env}.glownet.com/admins/events/#{@event.slug}"
  end

  def add_customers
    customer_common = { agreed_on_registration: true, agreed_event_condition: true, birthdate: Date.new(rand(1900..2000), rand(1..12), rand(1..28)) }
    @event.customers.create!(customer_common.merge(first_name: "Customer", last_name: "With ticket", email: "with_ticket@glownet.com", password: "test", password_confirmation: "test"))
    @event.customers.create!(customer_common.merge(first_name: "Customer", last_name: "With banned ticket", email: "with_banned_ticket@glownet.com", password: "test", password_confirmation: "test"))
    @event.customers.create!(customer_common.merge(first_name: "Customer", last_name: "Without ticket", email: "without_ticket@glownet.com", password: "test", password_confirmation: "test"))
    @event.customers.create!(customer_common.merge(first_name: "Customer", last_name: "With gtag", email: "with_gtag@glownet.com", password: "test", password_confirmation: "test"))
    @event.customers.create!(customer_common.merge(first_name: "Customer", last_name: "With banned gtag", email: "with_banned_gtag@glownet.com", password: "test", password_confirmation: "test"))
    @event.customers.create!(customer_common.merge(first_name: "Customer", last_name: "Without gtag", email: "without_gtag@glownet.com", password: "test", password_confirmation: "test"))
    columns = %w( event_id first_name last_name email encrypted_password agreed_on_registration agreed_event_condition birthdate ).map(&:to_sym)
    values = (1..100_000).map do |i|
      [@event.id, "Test", "Customer", "email#{i}@company#{i}.com", "$2a$11$e/LE.qIt9X1ojiBs5uyen.yJuABaecYPmckXo5H55w4KeTu25E5GW"] + customer_common.values
    end
    Customer.import columns, values, validate: false
  end

  def add_accesses
    accesses = [
      { name: "Day", mode: "permanent_strict", credential: true},
      { name: "Night", mode: "counter", credential: false},
      { name: "VIP", mode: "permanent", credential: false},
      { name: "Camping", mode: "permanent", credential: false},
      { name: "Staff", mode: "permanent", credential: false},
      { name: "Glownet Staff", mode: "permanent", credential: false}
    ]

    accesses.each do |access|
      Access.create!(event_id: @event.id,
                     name: access[:name],
                     step: 1,
                     min_purchasable: 0,
                     max_purchasable: 1,
                     initial_amount: 0,
                     entitlement_attributes: { event_id: @event.id, mode: access[:mode], })
    end
  end

  def add_packs
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
      p = Pack.new(event_id: @event.id,
                   name: pack[:name],
                   step: 1,
                   min_purchasable: 0,
                   max_purchasable: 1,
                   initial_amount: 0)
     pack[:catalog_items].each do |ci|
       item = @event.catalog_items.find_by(name: ci[:name], event: @event)
       p.pack_catalog_items.build(catalog_item: item, amount: ci[:amount] ).save
     end

     p.save! # Because association validation in pack model
    end
  end

  def add_products
    10.times do |index|
      @event.products.create!(name: "Product #{index + 1}", is_alcohol: [true, false].sample)
    end

    10.times do |index|
      @event.products.create!(name: "Market #{index + 1}", is_alcohol: [true, false].sample)
    end
  end

  def add_ticket_types
    company = Company.find_or_add_by(name: "Glownet")
    agreement = CompanyEventAgreement.create!(event: @event, company: company)

    event.catalog_items.each do |catalog_item|
      @event.ticket_types.create!(company_event_agreement: agreement,
                                          catalog_item: catalog_item,
                                          company_code: Time.zone.now.to_i + rand(10000),
                                          name: catalog_item.name)
    end
  end

  def add_tickets
    ticket_types = TicketType.where(event: @event)

    ticket_types.each do |tt|
      5.times do
        @event.tickets.create!(ticket_type: tt, code: SecureRandom.hex(16).upcase, redeemed: false)
      end
    end
  end

  def add_checkin_stations
    @event.stations.create!(name: "Checkin", group: "access", category: "check_in")
    @event.stations.create!(name: "Dummy Checkin", group: "access", category: "ticket_validation")
  end

  def add_access_control_stations
    accesses = [{ name: "Day", direction: 1 }, { name: "Day", direction: -1 }]
    station = @event.stations.create!(name: "Access Control", group: "access", category: "access_control")

    accesses.each do |access|
      item = CatalogItem.find_by(name: access[:name], event: @event)
      station.access_control_gates.create(direction: access[:direction], access: item, station: station)
    end
  end

  def add_box_office_stations
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

  def add_staff_accreditation_stations
    station = @event.stations.create!(name: "Staff Accreditation", group: "access", category: "staff_accreditation")
    items = ["Staff", "Glownet Staff"]

    items.each do |item_name|
      item = CatalogItem.find_by(name: item_name, event: @event)
      station.station_catalog_items.create(price: 0, catalog_item: item, station: station)
    end
  end

  def add_vendor_stations
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

  def add_bar_stations
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

  def add_topup_stations
    @event.stations.create!(name: "Topup/Refund", group: "monetary", category: "top_up_refund")
  end
end
