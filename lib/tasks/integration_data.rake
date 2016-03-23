require "database_cleaner"
include Benchmark

namespace :db do
  data = [
    "Events",
    "Customers",
    "CustomerEventProfiles",
    "Accesses",
    "CredentialTypes",
    "Packs",
    "Products",
    "Companies",
    "CompanyTicketTypes",
    "Tickets",
    "TicketAssignments",
    "Gtags",
    "GtagAssignments",
    "BoxOffices",
    "PointOfSales"
  ]

  desc "Fill database with sample data"
  task integration_data: :environment do

    @companies = 3
    @customers = 200
    @accesses = 10
    @credential_types = 10
    @packs = 15
    @products = 15
    @company_ticket_types = 15
    @tickets = 200
    @gtags =  180 # Less than customers is prefered
    @box_offices = 10

    Benchmark.benchmark(CAPTION, 25, FORMAT, "TOTAL:") do |x|
      total = []
      data.each do |f|
        total << x.report(f) { eval("create_#{f.underscore}") }
      end
      puts "-----------------------------------------------------------------------"
      [total.inject(:+)]
    end
  end

  def create_events
    name = "Event #{DateTime.now.to_s(:number)}"
    event_params = FactoryGirl.attributes_for(:event, name: name, slug: name.parameterize)
    EventCreator.new(event_params).save
  end

  def create_customers
    event = Event.last
    customers = []

    @customers.times do |index|
      customers.push({ event_id: event.id,
        first_name: "Customer #{index}",
        last_name: "Glownet",
        email: "customer#{index}#{DateTime.now.to_s(:number)}@example.com",
        agreed_on_registration: [true, false].sample,
        phone: "512 2301 440",
        country: "ES",
        gender: %w(male female).sample,
        birthdate: Date.new(rand(1900..2000), rand(1..12), rand(1..28)),
        postcode: "28012",
        agreed_event_condition: [true, false].sample })
    end

    Customer.bulk_insert_in_batches(customers, batch_size: 50000, delay: 0, validate: false)
  end

  def create_customer_event_profiles
    event = Event.last
    customer_profiles = []
    @customers.times do |index|
      customer_profiles << { event_id: event.id, customer_id: index + 1 }
    end

    CustomerEventProfile.bulk_insert_in_batches(customer_profiles,
                                                batch_size: 50000,
                                                delay: 0,
                                                validate: false)
  end

  def create_accesses
    event = Event.last
    @accesses.times do |index|
      Access.create!(catalog_item_attributes: { event_id: event.id,
                                                name: "Access #{index}",
                                                step: rand(5),
                                                min_purchasable: 1,
                                                max_purchasable: rand(100),
                                                initial_amount: 0 },
                     entitlement_attributes: {
                       event_id: event.id,
                       infinite: [true, false].sample,
                       memory_length: 1,
                       memory_position: rand(1..2) })
    end
  end

  def create_packs
    @event = Event.last
    @packs.times do |index|
      pack = Pack.create!(catalog_item_attributes: { event_id: @event.id,
                                                     name: "Pack #{index}",
                                                     step: rand(5),
                                                     min_purchasable: 1,
                                                     max_purchasable: rand(100),
                                                     initial_amount: 0 })
     pack.pack_catalog_items
         .build(catalog_item_id: @event.catalog_items.map(&:catalogable_id).sample, amount: rand(1..50))
         .save
    end

  end

  def create_products
    event = Event.last
    products = []

    @products.times do |index|
      products.push({ event_id: event.id,
                     name: "Product #{DateTime.now.to_s(:number)}",
                     description: "This is a description",
                     is_alcohol: [true, false].sample })
    end
    Product.bulk_insert_in_batches(products, batch_size: 50000, delay: 0, validate: false)
  end

  def create_credential_types
    @event = Event.last
    @credential_types.times do |index|
      CredentialType.create!(catalog_item_id: @event.catalog_items.map(&:catalogable_id).sample,
                             memory_position: rand(100))
    end
  end

  def create_companies
    event = Event.last
    @companies.times do
      CompanyEventAgreement.create!(event: event, company: FactoryGirl.create(:company))
    end
  end

  def create_company_ticket_types
    event = Event.last
    credential_types = CredentialType.joins(:company_ticket_types)
                        .where(company_ticket_types: { event: event }).pluck(:id)
    ticket_types = []
    @company_ticket_types.times do |index|
      ticket_types.push({ event_id: event.id,
                          company_event_agreement_id: @event.company_event_agreements.pluck(:id).sample,
                          credential_type_id: credential_types.sample,
                          name: "Company Ticket Type #{rand(100)}",
                          company_code: "#{index}AT#{DateTime.now.to_s(:number)}"})
    end
    CompanyTicketType.bulk_insert_in_batches(ticket_types,
                                             batch_size: 50000,
                                             delay: 0,
                                             validate: false)
  end

  def create_tickets
    event = Event.last
    agreements_count = CompanyEventAgreement.where(event: event).count

    tickets = []

    @tickets.times do |index|
      tickets.push({ event_id: event.id,
                     company_ticket_type_id: rand(1..agreements_count),
                     code: "#{index}AT#{DateTime.now.to_s(:number)}",
                     credential_redeemed: [true, false].sample })
    end
    Ticket.bulk_insert_in_batches(tickets, batch_size: 50000, delay: 0, validate: false)
  end

  def create_ticket_assignments
    event = Event.last
    ceps = CustomerEventProfile.where(event: event).pluck(:id)
    assignments = []

    Ticket.where(event: event).each do |ticket|
      assignments.push({ credentiable_id: ticket.id,
                         credentiable_type: "Ticket",
                         customer_event_profile_id: ceps.sample })
    end

    CredentialAssignment.bulk_insert_in_batches(assignments,
                                                batch_size: 50000,
                                                delay: 0,
                                                validate: false)
  end

  def create_gtags
    event = Event.last
    agreements = CompanyEventAgreement.where(event: event).pluck(:id)

    gtags = []

    @gtags.times do |index|
      gtags.push({ event_id: event.id,
                   company_ticket_type_id: agreements.sample,
                   tag_serial_number: "SERIAL#{index}AT#{DateTime.now.to_s(:number)}",
                   tag_uid: "UID#{index}AT#{DateTime.now.to_s(:number)}",
                   credential_redeemed: [true, false].sample })
    end
    Gtag.bulk_insert_in_batches(gtags, batch_size: 50000, delay: 0, validate: false)
  end

  def create_gtag_assignments
    event = Event.last
    ceps = CustomerEventProfile.where(event: event).pluck(:id)
    assignments = []

    Gtag.where(event: event).each do |gtag|
      assignments.push({ credentiable_id: gtag.id,
                         credentiable_type: "Gtag",
                         customer_event_profile_id: ceps.sample })
    end

    CredentialAssignment.bulk_insert_in_batches(assignments,
                                                batch_size: 50000,
                                                delay: 0,
                                                validate: false)
  end

  def create_box_offices
    @event = Event.last
    @box_offices.times do |index|
      type = StationType.find_by(name: "box_office")
      station = Station.create!(station_type: type, name: "Box Office #{index}", event: @event)
      40.times do |i|
        station.station_catalog_items
                .new(price: rand(1.0...20.0),
                     catalog_item_id: @event.catalog_items.map(&:catalogable_id).sample,
                     station_parameter_attributes: { station_id: station.id }).save
      end
    end
  end

  def create_point_of_sales
    event = Event.last

    @box_offices.times do |index|
      type = StationType.find_by(name: "point_of_sales")
      station = Station.create!(station_type: type, name: "POS #{index}", event: @event)
      event.products.each do |product|
        station.station_products
          .new(price: rand(1.0...20.0),
               product: product,
               station_parameter_attributes: { station_id: station.id }).save
      end
    end
  end
end
