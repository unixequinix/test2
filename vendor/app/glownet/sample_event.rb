class SampleEvent
  def self.run(user = nil)
    name = user ? "#{user.username || user.email} fest #{user.events.count + 1}" : "Event v#{Time.zone.now.to_s(:number)}"
    name += " v#{Time.zone.now.to_s(:number)}" if Event.find_by(name: name)
    @event = Event.create(name: name, start_date: Time.zone.now.beginning_of_day, end_date: (Time.zone.now. + 3.days).end_of_day, support_email: "support@glownet.com", currency: "EUR", private_zone_password: 'a', fast_removal_password: 'a', open_devices_api: true, open_api: true, open_portal: true, open_refunds: true, open_topups: true, open_tickets: true, open_gtags: true)
    @event.initial_setup!

    data = %w[customers accesses packs ticket_types tickets checkin_stations box_office_stations access_control_stations staff_accreditation_stations vendor_stations bar_stations topup_stations]
    data.each { |d| method("create_#{d}").call }

    @event
  end

  def self.create_customers
    @event.customers.create!(first_name: "Vicentest", last_name: "Test", email: "test@test.com", agreed_on_registration: true, anonymous: false, password: "password123", password_confirmation: "password123", confirmed_at: Time.zone.now)
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
      { name: "Day + Night", catalog_items: [{ name: "Day", amount: 1 }, { name: "Night", amount: 1 }], credential: true },
      { name: "Day + VIP", catalog_items: [{ name: "Day", amount: 1 }, { name: "VIP", amount: 1 }], credential: true },
      { name: "Night + VIP", catalog_items: [{ name: "Night", amount: 1 }, { name: "VIP", amount: 1 }], credential: true },
      { name: "Day + Camping", catalog_items: [{ name: "Day", amount: 1 }, { name: "Camping", amount: 1 }], credential: true },
      { name: "Day + Night + VIP", catalog_items: [{ name: "Day", amount: 1 }, { name: "Night", amount: 1 }, { name: "VIP", amount: 1 }], credential: true },
      { name: "50 sta + 15 virtual", catalog_items: [{ name: "CRD", amount: 50 }, { name: "Virtual", amount: 15 }], credential: false }
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
    @event.accesses.each do |catalog_item|
      @event.ticket_types.create!(catalog_item: catalog_item, company_code: Time.zone.now.to_i + rand(10_000), name: catalog_item.name, company: "Glownet")
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
    accesses = %w[Day Night VIP]
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
    credit_id = @event.credit.id.to_s
    virtual_credit_id = @event.virtual_credit.id.to_s

    products = [
      { name: "Pin", prices: { credit_id => { price: 0.01 }, virtual_credit_id => { price: 0.01 } } },
      { name: "Pin pack", prices: { credit_id => { price: 0.05 }, virtual_credit_id => { price: 0.05 } } },
      { name: "Twin Pin", prices: { credit_id => { price: 0.1 }, virtual_credit_id => { price: 0.1 } } },
      { name: "Nickle", prices: { credit_id => { price: 0.5 }, virtual_credit_id => { price: 0.5 } } },
      { name: "Water", prices: { credit_id => { price: 1 }, virtual_credit_id => { price: 1 } } },
      { name: "T-Shirt", prices: { credit_id => { price: 5 }, virtual_credit_id => { price: 5 } } },
      { name: "T-Shirt Pack", prices: { credit_id => { price: 10 }, virtual_credit_id => { price: 10 } } },
      { name: "Statue", prices: { credit_id => { price: 20 }, virtual_credit_id => { price: 20 } } },
      { name: "Jacket", prices: { credit_id => { price: 25 }, virtual_credit_id => { price: 25 } } },
      { name: "Suit", prices: { credit_id => { price: 50 }, virtual_credit_id => { price: 50 } } }
    ]
    station = @event.stations.create!(name: "Merchandise", category: "vendor")

    products.each.with_index do |p, index|
      station.products.create(prices: p[:prices], name: p[:name], station: station, position: index + 1, is_alcohol: [true, false].sample)
    end
  end

  def self.create_bar_stations
    credit_id = @event.credit.id.to_s
    products = [
      { name: "Coke", prices: { credit_id => { price: 1 } } },
      { name: "Coke Zero", prices: { credit_id => { price: 2 } } },
      { name: "Aquarius", prices: { credit_id => { price: 3 } } },
      { name: "Beer", prices: { credit_id => { price: 4 } } },
      { name: "Craft Beer", prices: { credit_id => { price: 5 } } },
      { name: "Gin & Tonic", prices: { credit_id => { price: 10 } } }
    ]
    station = @event.stations.create!(name: "Main Bar", category: "bar")

    products.each do |p|
      station.products.create(prices: p[:prices], name: p[:name], station: station, is_alcohol: [true, false].sample)
    end
  end

  def self.create_topup_stations
    @event.stations.create!(name: "Topup/Refund", category: "top_up_refund")
  end
end
