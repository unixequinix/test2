namespace :db do
  desc 'Fill database with sample data'
  task create_admin_access: :environment do
    puts '----------------------------------------'
    puts 'Creating admin access'
    puts '----------------------------------------'
    make_admins
  end

  desc 'Fill database with sample data'
  task populate: :environment do
    puts '----------------------------------------'
    puts 'Creating fake data'
    puts '----------------------------------------'
    make_events
    make_companies
    make_company_event_agreements
    make_accesses
    # make_vouchers
    make_packs
    make_company_ticket_types
    make_tickets
    make_gtags
    make_customers
    make_profiles
    make_credential_assignments
    make_orders
  end

  desc 'Create stations'
  task stations: :environment do
    puts 'Creating fake data'
    puts '----------------------------------------'
    make_portal_station
  end

  def make_admins
    puts "Create admins"
    puts "----------------------------------------"
    Admin.destroy_all
    Admin.create(email: 'admin@test.com',
                 encrypted_password: Authentication::Encryptor.digest("password"))
  end

  def make_events
    puts "Create events"
    puts "----------------------------------------"
    Event.destroy_all
    YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", "events.yml")).each do |data|
      event = EventCreator.new(name: data['name'],
                               location: data['location'],
                               start_date: data['start_date'],
                               end_date: data['end_date'],
                               description: data['description'],
                               currency: data['currency'],
                               token_symbol: data['token_symbol'],
                               host_country: data['host_country'],
                               support_email: data['support_email'],
                               features: data['features'])
      event.save
    end
  end

  def make_tickets
    puts 'Create tickets'
    puts '----------------------------------------'
    Ticket.destroy_all
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'tickets.yml')).each do |data|
        ticket = Ticket.new(event_id: event.id,
                            code: data['code'],
                            company_ticket_type_id: data['company_ticket_type_id'])
        ticket.save!
      end
    end
  end

  def make_companies
    puts 'Create companies'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'companies.yml')).each do |data|
        Company.create!(name: data['name'])
      end
    end
  end
  def make_company_event_agreements
    puts 'Create company event agreements'
    puts '----------------------------------------'
    Event.all.each do |event|
      Company.all.each do |company|
        CompanyEventAgreement.create!(event: event, company: company)
      end
    end
  end

  def make_accesses
    puts 'Create accesses'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'accesses.yml')).each do |data|
        Access.create!(catalog_item_attributes: { event_id: event.id,
                                                  name: data['name'],
                                                  step: data['step'],
                                                  min_purchasable: data['min_purchasable'],
                                                  max_purchasable: data['max_purchasable'],
                                                  initial_amount: data['initial_amount'] },
                       entitlement_attributes: { event_id: event.id,
                                                      mode: data['mode'],
                                                      memory_length: data['memory_length'] } )
      end
    end
  end

  def make_vouchers
    puts 'Create vouchers'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'vouchers.yml')).each do |data|
        Voucher.create!(catalog_item_attributes: { event_id: event.id,
                                                  name: data['name'],
                                                  step: data['step'],
                                                  min_purchasable: data['min_purchasable'],
                                                  max_purchasable: data['max_purchasable'],
                                                  initial_amount: data['initial_amount'] },
                       entitlement_attributes: { event_id: event.id,
                                                      mode: data['mode'],
                                                      memory_length: data['memory_length'] } )
      end
    end
  end

  def make_packs
    puts 'Create packs'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'packs.yml')).each do |data|
        @pack = Pack.create!(catalog_item_attributes: { event: event,
                                                        name: data["name"],
                                                        step: data["step"],
                                                        min_purchasable: data["min_purchasable"],
                                                        max_purchasable: data["max_purchasable"],
                                                        initial_amount: data["initial_amount"] })
        data['pack_catalog_item'].map do |item|
          PackCatalogItem.create!(pack: @pack,
                                  catalog_item_id: item['catalog_item_id'],
                                  amount: item['amount'])
        end
      end
    end
  end

  def make_portal_station
    puts 'Create portal station'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'stations.yml')).each do |data|
        @station = Station.find_by(
                        station_type: StationType.find_by(name: data['station_type']),
                        event: event)
        data['station_catalog_items'].each do |station_catalog_item|
          StationCatalogItem.create!(
              price: station_catalog_item["price"],
              catalog_item: CatalogItem.find(station_catalog_item['catalog_item']),
              station_parameter_attributes: { station: @station }
          )
        end
      end
    end
  end

  def make_company_ticket_types
    puts 'Create company ticket types'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'company_ticket_types.yml')).each_with_index do |data, index|
        @credential_type = CredentialType.create!(catalog_item: CatalogItem.find(index+1))
        CompanyTicketType.create!(company_code: data['company_code'],
                                  name: data['name'],
                                  event: event,
                                  company_event_agreement_id: data['company_event_agreement_id'],
                                  credential_type_id: @credential_type.id )
      end
    end
  end

  def make_gtags
    puts 'Create gtags'
    puts '----------------------------------------'
    Gtag.destroy_all
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'gtags.yml')).each do |data|
        gtag = Gtag.new(
          event_id: event.id,
          tag_serial_number: data['tag_serial_number'],
          tag_uid: data['tag_uid']
        )
        gtag.save!
      end
    end
  end

  def make_customers
    puts 'Create customers'
    puts '----------------------------------------'
    Customer.destroy_all
    Customer.create(
      email: 'customer@test.com',
      encrypted_password: Authentication::Encryptor.digest("password"),
      first_name: 'Alejandro',
      last_name: 'González Núñez',
      agreed_on_registration: true,
      event_id: 1)
    Customer.create(
      email: 'customer2@test.com',
      encrypted_password: Authentication::Encryptor.digest("password"),
      first_name: 'Pedro',
      last_name: 'De La Rosa',
      agreed_on_registration: true,
      event_id: 1)
  end

  def make_profiles
    puts 'Create customer event profiles'
    puts '----------------------------------------'
    Profile.destroy_all
    Profile.create(customer_id: 1, event_id: 1)
    Profile.create(customer_id: 2, event_id: 1)
  end

  def make_credential_assignments
    puts 'Create credential assignments'
    puts '----------------------------------------'
    CredentialAssignment.destroy_all
    CredentialAssignment.create(
      aasm_state: "assigned",
      credentiable_id: 10,
      credentiable_type: "Ticket",
      profile_id: 1)
    CredentialAssignment.create(
      aasm_state: "assigned",
      credentiable_id: 5,
      credentiable_type: "Gtag",
      profile_id: 2)
  end

  def make_orders
    puts 'Create orders'
    puts '----------------------------------------'
    Profile.all.each do |profile|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'orders.yml')).each do |data|
        @order = Order.new(number: "#{profile.id}#{data['number']}" * 4,
                           aasm_state: data['aasm_state'],
                           profile: profile)
        @order.order_items << data['order_items'].map do |order_item|
                                  OrderItem.new(catalog_item_id: order_item['catalog_item_id'],
                                    amount: order_item['amount'],
                                    total: order_item['total'])
                              end
        @order.save
      end
    end
  end
end
