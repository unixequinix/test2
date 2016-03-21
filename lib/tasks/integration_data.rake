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
    "Companies",
    "CompanyTicketTypes",
    "Tickets",
    "TicketAssignments",
    "Gtags",
    "GtagAssignments",
    "BoxOffices"
  ]

  desc "Fill database with sample data"
  task integration_data: :environment do

    @companies = 3
    @customers = 50
    @accesses = 20
    @credential_types = 20
    @packs = 10
    @company_ticket_types = 20
    @tickets = 50
    @gtags =  40 # Less than customers is prefered
    @box_offices = 5

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
    event = Event.last
    @packs.times do |index|
      pack = Pack.create!(catalog_item_attributes: { event_id: event.id,
                                                     name: "Pack #{index}",
                                                     step: rand(5),
                                                     min_purchasable: 1,
                                                     max_purchasable: rand(100),
                                                     initial_amount: 0 })
     pack.pack_catalog_items
         .build(catalog_item_id: rand(1..CatalogItem.count), amount: rand(50))
         .save
    end

  end

  def create_credential_types
    @credential_types.times do |index|
      CredentialType.create!(catalog_item_id: rand(1..CatalogItem.count), memory_position: rand(100))
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
    ticket_types = []
    @company_ticket_types.times do |index|
      ticket_types.push({ event_id: event.id,
                          company_event_agreement_id: rand(1..CompanyEventAgreement.count),
                          credential_type_id: rand(1..CredentialType.count),
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
    ceps_count = CustomerEventProfile.where(event: event).count
    assignments = []

    Ticket.where(event: event).each do |ticket|
      assignments.push({ credentiable_id: ticket.id,
                         credentiable_type: "Ticket",
                         customer_event_profile_id: rand(1..ceps_count) })
    end

    CredentialAssignment.bulk_insert_in_batches(assignments,
                                                batch_size: 50000,
                                                delay: 0,
                                                validate: false)
  end

  def create_gtags
    event = Event.last
    agreements_count = CompanyEventAgreement.where(event: event).count

    gtags = []

    @gtags.times do |index|
      gtags.push({ event_id: event.id,
                   company_ticket_type_id: rand(1..agreements_count),
                   tag_serial_number: "SERIAL#{index}AT#{DateTime.now.to_s(:number)}",
                   tag_uid: "UID#{index}AT#{DateTime.now.to_s(:number)}",
                   credential_redeemed: [true, false].sample })
    end
    Gtag.bulk_insert_in_batches(gtags, batch_size: 50000, delay: 0, validate: false)
  end

  def create_gtag_assignments
    event = Event.last
    ceps_count = CustomerEventProfile.where(event: event).count
    assignments = []

    Gtag.where(event: event).each do |gtag|
      assignments.push({ credentiable_id: gtag.id,
                         credentiable_type: "Gtag",
                         customer_event_profile_id: rand(1..ceps_count) })
    end

    CredentialAssignment.bulk_insert_in_batches(assignments,
                                                batch_size: 50000,
                                                delay: 0,
                                                validate: false)
  end

  def create_box_offices
    @box_offices.times do |index|
      type = StationType.find_by(name: "box_office")
      station = Station.create!(station_type: type, name: "Box Office #{index}", event: Event.last)
      40.times do |i|
        station.station_catalog_items
                .new(price: rand(1.0...20.0),
                     catalog_item_id: rand(1..CatalogItem.count),
                     station_parameter_attributes: { station_id: station.id })
                .save
      end
    end
  end
end
