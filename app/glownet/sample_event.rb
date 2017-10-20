class SampleEvent # rubocop:disable all
  # rubocop:disable all
  def self.run
    @event = Event.create(name: "Event v#{Time.zone.now.to_s(:number)}", start_date: Time.zone.now, end_date: Time.zone.now + 4.days, support_email: "support@glownet.com", currency: "EUR", private_zone_password: 'a', fast_removal_password: 'a', open_ticketing_api: true, open_devices_api: true, open_api: true, open_portal: true, open_refunds: true, open_topups: true, open_tickets: true, open_gtags: true)
    @event.initial_setup!

    data = %w(customers accesses packs ticket_types tickets checkin_stations box_office_stations access_control_stations staff_accreditation_stations vendor_stations bar_stations topup_stations)
    data.each { |d| eval("create_#{d}") }

    @event
  end

  def self.create_customers
    @event.customers.create!(first_name: "Vicentest", last_name: "Test", email: "test@test.com", agreed_on_registration: true, phone: "512 2301 440", country: "ES", gender: "male", birthdate: Date.new(rand(1900..2000), rand(1..12), rand(1..28)), postcode: "28012", password: "test", password_confirmation: "test")
  end

  def self.create_accesses
    accesses = [
      { name: "Day", mode: "permanent_strict", credential: true },
      { name: "Night", mode: "counter", credential: false },
      { name: "VIP", mode: "permanent", credential: false },
      { name: "Camping", mode: "permanent", credential: false },
      { name: "Staff", mode: "permanent", credential: false },
      { name: "Glownet Staff", mode: "permanent", credential: false }
    ]

    accesses.each do |access|
      @event.accesses.create!(name: access[:name], mode: access[:mode])
    end
  end

  def self.create_packs
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
      p = Pack.new(event_id: @event.id, name: pack[:name])
      pack[:catalog_items].each do |ci|
        item = @event.catalog_items.find_by(name: ci[:name])
        p.pack_catalog_items.build(catalog_item_id: item.id, amount: ci[:amount])
      end

      p.save! # Because association validation in pack model
    end
  end

  def self.create_ticket_types
    company = @event.companies.find_or_create_by(name: "Glownet")

    @event.accesses.each do |catalog_item|
      @event.ticket_types.create!(company: company,
                                  catalog_item: catalog_item,
                                  company_code: Time.zone.now.to_i + rand(10_000),
                                  name: catalog_item.name)
    end
  end

  def self.create_tickets
    ticket_types = TicketType.where(event: @event)

    ticket_types.each do |tt|
      5.times do
        @event.tickets.create!(ticket_type: tt, code: SecureRandom.hex(16).upcase, redeemed: false)
      end
    end
  end

  def self.create_checkin_stations
    @event.stations.create!(name: "Checkin", category: "check_in")
    @event.stations.create!(name: "Dummy Checkin", category: "ticket_validation")
  end

  def self.create_access_control_stations
    accesses = %w(Day Night VIP)
    accesses.each do |access_name|
      item = @event.catalog_items.find_by(name: access_name)
      station = @event.stations.create!(name: "#{access_name} IN", category: "access_control")
      station.access_control_gates.create(direction: 1, access: item)

      station = @event.stations.create!(name: "#{access_name} OUT", category: "access_control")
      station.access_control_gates.create(direction: -1, access: item)
    end
  end

  def self.create_box_office_stations
    station = @event.stations.create!(name: "Box office", category: "box_office")

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

  def self.create_staff_accreditation_stations
    station = @event.stations.create!(name: "Staff Accreditation", category: "staff_accreditation")
    items = ["Staff", "Glownet Staff"]

    items.each do |item_name|
      item = CatalogItem.find_by(name: item_name, event: @event)
      station.station_catalog_items.create(price: 0, catalog_item: item, station: station)
    end
  end

  def self.create_vendor_stations
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
    station = @event.stations.create!(name: "MARKET 1", category: "vendor")

    products.each.with_index do |p, index|
      station.products.create(price: p[:price], name: p[:name], station: station, position: index + 1, is_alcohol: [true, false].sample)
    end
  end

  def self.create_bar_stations
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
    station = @event.stations.create!(name: "BAR 1", category: "bar")

    products.each do |p|
      station.products.create(price: p[:price], name: p[:name], station: station, is_alcohol: [true, false].sample)
    end
  end

  def self.create_topup_stations
    @event.stations.create!(name: "Topup/Refund", category: "top_up_refund")
  end
end
