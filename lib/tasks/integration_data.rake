require "database_cleaner"
include Benchmark

namespace :db do
  @events = 1
  @companies = 3
  @customers = 20000
  @accesses = 20
  @credential_types = 20
  @company_ticket_types = 20
  @tickets = 1500
  @gtags =  1200 # Less than customers is prefered

  data = [
    "Events",
    "Customers",
    "CustomerEventProfiles",
    #"Credits",
    "Accesses",
    "CredentialTypes",
    "Companies",
    "CompanyTicketTypes",
    "Tickets",
    "TicketAssignments",
    "Gtags",
    "GtagAssignments"
  ]

  desc "Fill database with sample data"
  task integration_data: :environment do
    #DatabaseCleaner.clean_with(:truncation)

    Benchmark.benchmark(CAPTION, 25, FORMAT, "TOTAL:") do |x|
      Faker::Config.locale = :es
      total = []
      data.each do |f|
        total << x.report(f) { eval("create_#{f.underscore}") }
      end
      puts "-----------------------------------------------------------------------"
      [total.inject(:+)]
    end
  end

  def create_events
    @events.times do |index|
      name = "Event #{index} #{rand(100)}"
      event_params = FactoryGirl.attributes_for(:event, name: name, slug: name.parameterize)
      EventCreator.new(event_params).save
    end
  end

  def create_customers
    Event.all.each do |event|
      customers = []

      @customers.times do |index|
        customers.push({ event_id: event.id,
          name: "Customer #{index}",
          surname: "Glownet",
          email: "customer#{index}_#{event.id}@example.com",
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
  end

  def create_customer_event_profiles
    Event.all.each do |event|
      customer_profiles = []
      @customers.times do |index|
        customer_profiles << { event_id: event.id, customer_id: index + 1 }
      end

      CustomerEventProfile.bulk_insert_in_batches(customer_profiles,
                                                  batch_size: 50000,
                                                  delay: 0,
                                                  validate: false)
    end
  end

  def create_credits
    Event.all.each do |event|
      Credit.create!(standard: true,
                     currency: "EUR",
                     value: 1,
                     catalog_item_attributes: { event_id: event.id,
                                                name: "Standard Credit",
                                                step: 1,
                                                min_purchasable: 1,
                                                max_purchasable: 10000,
                                                initial_amount: 0 })
    end
  end

  def create_accesses
    Event.all.each do |event|
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
                         memory_position: 3 })
      end
    end
  end

  def create_credential_types
    @credential_types.times do |index|
      CredentialType.create!(catalog_item_id: rand(1..CatalogItem.count), memory_position: rand(100))
    end
  end

  def create_companies
    Event.all.each do |event|
      @companies.times do
        CompanyEventAgreement.create!(event: event, company: FactoryGirl.create(:company))
      end
    end
  end

  def create_company_ticket_types
    Event.all.each do |event|
      ticket_types = []
      @company_ticket_types.times do |index|
        ticket_types.push({ event_id: event.id,
                            company_event_agreement_id: rand(1..CompanyEventAgreement.count),
                            credential_type_id: rand(1..CredentialType.count),
                            name: "Company Ticket Type #{rand(100)}",
                            company_code: "#{index}AB#{rand(1000)}"})
      end
      CompanyTicketType.bulk_insert_in_batches(ticket_types,
                                               batch_size: 50000,
                                               delay: 0,
                                               validate: false)
    end
  end

  def create_tickets
    Event.all.each do |event|
      agreements_count = CompanyEventAgreement.where(event: event).count

      tickets = []

      @tickets.times do |index|
        tickets.push({ event_id: event.id,
                       company_ticket_type_id: rand(1..agreements_count),
                       code: "AA#{index}ZZ#{rand(1000)}BB#{rand(500)}",
                       credential_redeemed: [true, false].sample })
      end
      Ticket.bulk_insert_in_batches(tickets, batch_size: 50000, delay: 0, validate: false)
    end
  end

  def create_ticket_assignments
    Event.all.each do |event|
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
  end

  def create_gtags
    Event.all.each do |event|
      agreements_count = CompanyEventAgreement.where(event: event).count

      gtags = []

      @gtags.times do |index|
        gtags.push({ event_id: event.id,
                     company_ticket_type_id: rand(1..agreements_count),
                     tag_serial_number: "RTW#{rand(100)}ASD",
                     tag_uid: "#{index}ZXA#{rand(1000)}",
                     credential_redeemed: [true, false].sample })
      end
      Gtag.bulk_insert_in_batches(gtags, batch_size: 50000, delay: 0, validate: false)
    end
  end

  def create_gtag_assignments
    Event.all.each do |event|
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
  end
end
