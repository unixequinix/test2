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
    Faker::Config.locale = :es
    puts '----------------------------------------'
    puts 'Creating fake data'
    puts '----------------------------------------'
    make_events
    make_companies
    make_preevent_items
    make_preevent_products
    make_preevent_product_items
    make_company_ticket_types
    make_tickets
    make_gtags
    make_customers
    make_customer_event_profiles
    make_credential_assignments
  end

  def make_admins
    puts "Create admins"
    puts "----------------------------------------"
    Admin.destroy_all
    Admin.create(email: 'admin@test.com', encrypted_password: Authentication::Encryptor.digest("password"))
  end

  def make_events
    puts "Create events"
    puts "----------------------------------------"
    Event.destroy_all
    YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", "events.yml")).each do |data|
      event = EventCreator.new(name: data['name'], location: data['location'], start_date: data['start_date'], end_date: data['end_date'], description: data['description'], currency: data['currency'], host_country: data['host_country'], support_email: data['support_email'], features: data['features'])
      event.save
    end
  end

  def make_tickets
    puts 'Create tickets'
    puts '----------------------------------------'
    Ticket.destroy_all
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'tickets.yml')).each do |data|
        ticket = Ticket.new(event_id: event.id, code: data['code'], company_ticket_type_id: data['company_ticket_type_id'])
        ticket.save!
      end
    end
  end

  def make_companies
    puts 'Create companies'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'companies.yml')).each do |data|
        company = Company.new(event_id: event.id, name: data['name'])
        company.save!
      end
    end
  end

  def make_preevent_items
    puts 'Create preevent items'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'preevent-items.yml')).each do |data|

        item = data['purchasable_type'].constantize.new(
          preevent_item_attributes: {
            event_id: event.id,
            name: data['name'],
            description: data['description']
          }
        )

        item.counter = data['counter'] if data['purchasable_type'] == 'Voucher'
        item.position = data['position'] if data['purchasable_type'] == 'CredentialType'

        item.save!
      end
    end
  end

  def make_preevent_products
    puts 'Create preevent products'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'preevent-products.yml')).each do |data|
        product = PreeventProduct.new(
          event_id: event.id,
          name: data['name'],
          min_purchasable: data['min_purchasable'],
          max_purchasable: data['max_purchasable'],
          price: data['price'],
          step: data['step'],
          initial_amount: data['initial_amount'],
          online: data['online']
        )
        product.save!(validate: false)
      end
    end
  end

  def make_preevent_product_items
    puts 'Create preevent product items'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'preevent-product-items.yml')).each do |data|
        preevent_product = PreeventProduct.find(data['product'])
        preevent_item = PreeventItem.find(data['item'])
        PreeventProductItem.create!(
          amount: data['amount'],
          preevent_product: preevent_product,
          preevent_item: preevent_item
        )
        preevent_product.preevent_items_counter
      end
    end
  end

  def make_company_ticket_types
    puts 'Create company ticket types'
    puts '----------------------------------------'
    Event.all.each do |event|
      YAML.load_file(Rails.root.join("lib", "tasks", "sample_data", 'company_ticket_types.yml')).each do |data|
        ticket = CompanyTicketType.new(
          company_ticket_type_ref: data['company_ticket_type_ref'],
          name: data['name'],
          event_id: event.id,
          company_id: data['company_id'],
          preevent_product_id: data['product_id']
        )
        ticket.save!
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
      name: 'Alejandro',
      surname: 'González Núñez',
      confirmed_at: '2015-04-21 13:39:18.381529',
      agreed_on_registration: true,
      event_id: 1)
    Customer.create(
      email: 'customer2@test.com',
      encrypted_password: Authentication::Encryptor.digest("password"),
      name: 'Pedro',
      surname: 'De La Rosa',
      confirmed_at: '2015-04-21 13:39:18.381529',
      agreed_on_registration: true,
      event_id: 1)
  end

  def make_customer_event_profiles
    puts 'Create customer event profiles'
    puts '----------------------------------------'
    CustomerEventProfile.destroy_all
    CustomerEventProfile.create(customer_id: 1, event_id: 1)
    CustomerEventProfile.create(customer_id: 2, event_id: 1)
  end

  def make_credential_assignments
    puts 'Create credential assignments'
    puts '----------------------------------------'
    CredentialAssignment.destroy_all
    CredentialAssignment.create(
      aasm_state: "assigned",
      credentiable_id: 10,
      credentiable_type: "Ticket",
      customer_event_profile_id: 1)
    CredentialAssignment.create(
      aasm_state: "assigned",
      credentiable_id: 5,
      credentiable_type: "Gtag",
      customer_event_profile_id: 2)
  end
end
