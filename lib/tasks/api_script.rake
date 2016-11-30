namespace :glownet do
  desc "Creates a basic event"
  task api_script: :environment do
    event_common = { start_date: DateTime.now, end_date: DateTime.now + 4.days, location: "Spain", support_email: "support@glownet.com", currency: "EUR", host_country: "Spain", gtag_name: "Wristband", token_symbol: "t" }
    @event = EventCreator.new(event_common.merge({ name: "PreEvent #{Time.now.to_i}", aasm_state: "launched"})).save

    data = ["customers", "accesses", "packs", "products", "ticket_types", "tickets", "checkin_stations", "box_office_stations", "access_control_stations", "staff_accreditation_stations", "vendor_stations", "bar_stations", "topup_stations"]

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
      @event.accesses.create!(name: access[:name],
                              step: 1,
                              min_purchasable: 0,
                              max_purchasable: 1,
                              initial_amount: 0,
                              entitlement_attributes: { event_id: @event.id, mode: access[:mode], })
    end
  end

  def add_packs
    packs = [
      { name: "Day + Night", catalog_items: [{ name: "Day", amount: 1 }, { name: "Night", amount: 1 }]},
      { name: "Day + VIP", catalog_items: [{ name: "Day", amount: 1 }, { name: "VIP", amount: 1 }]},
      { name: "Night + VIP", catalog_items: [{ name: "Night", amount: 1 }, { name: "VIP", amount: 1 }]},
      { name: "Day + Camping", catalog_items: [{ name: "Day", amount: 1 }, { name: "Camping", amount: 1 }]},
      { name: "Day + Night + VIP", catalog_items: [{ name: "Day", amount: 1 }, { name: "Night", amount: 1 }, { name: "VIP", amount: 1 }]},
      { name: "50e + 15e Free Pack", catalog_items: [{ name: "CRD", amount: 65 }]}
    ]

    packs.each do |pack|
      p = @event.packs.new(name: pack[:name], step: 1, min_purchasable: 0, max_purchasable: 1, initial_amount: 0)

      pack[:catalog_items].each do |ci|
       item = @event.catalog_items.find_by(name: ci[:name], event: @event)
       p.pack_catalog_items.build(catalog_item: item, amount: ci[:amount] ).save
     end

     p.save! # Because association validation in pack model
    end
  end

  def add_products
    10.times { |i| @event.products.create!(name: "Product #{i + 1}", is_alcohol: [true, false].sample) }
    10.times { |i| @event.products.create!(name: "Market #{i + 1}", is_alcohol: [true, false].sample) }
  end

  def add_ticket_types
    company = Company.find_or_add_by(name: "Glownet")
    agreement = @event.company_event_agreements.create!(company: company)

    event.catalog_items.each do |catalog_item|
      @event.ticket_types.create!(company_event_agreement: agreement,
                                  catalog_item: catalog_item,
                                  company_code: Time.zone.now.to_i + rand(10000),
                                  name: "#{company.name} - #{catalog_item.name}")
    end
  end

  def add_tickets
    @event.ticket_types.each do |tt|
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
    station = @event.stations.create!(name: "Access Control", group: "access", category: "access_control")
    item = @event.accesses.find_by_name("Day")
    station.access_control_gates.create(direction: 1, access: item)
    station.access_control_gates.create(direction: -1, access: item)
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
      station.station_catalog_items.create(price: i[:price], catalog_item: item)
    end
  end

  def add_staff_accreditation_stations
    station = @event.stations.create!(name: "Staff Accreditation", group: "access", category: "staff_accreditation")
    station.station_catalog_items.create(price: 0, catalog_item: @event.catalog_items.find_by_name("Staff"))
    station.station_catalog_items.create(price: 0, catalog_item: @event.catalog_items.find_by_name("Glownet Staff"))
  end

  def add_vendor_stations
    station = @event.stations.create!(name: "MARKET 1", group: "monetary", category: "vendor")

    10.times do |i|
      product = @event.products.find_by_name("Market #{i}")
      price = (rand * 100).round(2)
      station.station_products.create(price: price, product: product)
    end
  end

  def add_bar_stations
    station = @event.stations.create!(name: "BAR 1", group: "monetary", category: "bar")

    10.times do |i|
      product = @event.products.find_by_name("Product #{i}")
      station.station_products.create(price: i, product: product)
    end
  end

  def add_topup_stations
    @event.stations.create!(name: "Topup/Refund", group: "monetary", category: "top_up_refund")
  end
end
