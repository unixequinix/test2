namespace :db do

  desc "Fill database with sample data"
  task populate: :environment do
    Faker::Config.locale = :es
    puts "--------------------------------------------------------------------------------"
    puts "Creating fake data"
    puts "--------------------------------------------------------------------------------"
    make_customers
    make_entitlements
    make_ticket_types
    make_tickets
    make_credits
  end

  def make_customers

    puts "Create customers"
    puts "----------------------------------------"

    Customer.destroy_all
    Customer.create(email: 'customer@test.com', password: 'password', name: 'Alejandro', surname: 'González Núñez',     confirmed_at: '2015-04-21 13:39:18.381529')
    Customer.create(email: 'customer2@test.com', password: 'password', name: 'Pedro', surname: 'De La Rosa', confirmed_at: '2015-04-21 13:39:18.381529')
  end

  def make_entitlements

    puts "Create entitlements"
    puts "----------------------------------------"

    Entitlement.destroy_all
    YAML.load_file(Rails.root.join("db", "seeds", "entitlements.yml")).each do |data|
      Entitlement.create!(name: data['name'])
    end
  end

  def make_ticket_types

    puts "Create ticket types"
    puts "----------------------------------------"

    TicketType.destroy_all
    YAML.load_file(Rails.root.join("db", "seeds", "ticket_types.yml")).each do |data|
      ticket_type = TicketType.new(name: data['name'], company: data['company'], credit: data['credit'])
      data['entitlements'].each do |entitlement|
        ticket_type.entitlements << Entitlement.find_by(name: entitlement['name'])
      end
      ticket_type.save!
    end
  end

  def make_tickets

    puts "Create tickets"
    puts "----------------------------------------"

    Ticket.destroy_all
    YAML.load_file(Rails.root.join("db", "seeds", "tickets.yml")).each do |data|
      ticket = Ticket.new(number: data['number'])
      ticket.ticket_type = TicketType.find_by(name: data['ticket_type'])
      ticket.save!
    end
  end

  def make_rfid_tags

    puts "Create Rfid Tags"
    puts "----------------------------------------"

    RfidTag.destroy_all
    YAML.load_file(Rails.root.join("db", "seeds", "rfid_tags.yml")).each do |data|
      rfid_tag = RfidTag.new(tag_uid: data['tag_uid'], tag_serial_number: data['tag_serial_number'])
      rfid_tag.save!
    end
  end

  def make_credits

    puts "Create credits"
    puts "----------------------------------------"

    OnlineProduct.destroy_all
    Credit.destroy_all
    YAML.load_file(Rails.root.join("db", "seeds", "credits.yml")).each do |data|
      credit = Credit.new(standard: data['standard'])
      credit.online_product = OnlineProduct.new(name: data['name'], description: data['description'], price: data['price'], min_purchasable: data['min_purchasable'], max_purchasable: data['max_purchasable'], initial_amount: data['initial_amount'], step: data['step'])
      credit.save!
    end
  end

end