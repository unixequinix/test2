namespace :db do
  desc 'Fill database with sample data'
  task populate: :environment do
    Faker::Config.locale = :es
    puts '----------------------------------------'
    puts 'Creating fake data'
    puts '----------------------------------------'
    make_customers
    make_entitlements
    make_ticket_types
    make_tickets
    make_gtags
  end

  def make_customers
    puts 'Create customers'
    puts '----------------------------------------'
    Customer.destroy_all
    Customer.create(
      email: 'customer@test.com',
      password: 'password',
      name: 'Alejandro',
      surname: 'González Núñez',
      confirmed_at: '2015-04-21 13:39:18.381529',
      agreed_on_registration: true)
    Customer.create(
      email: 'customer2@test.com',
      password: 'password',
      name: 'Pedro',
      surname: 'De La Rosa',
      confirmed_at: '2015-04-21 13:39:18.381529',
      agreed_on_registration: true)
  end

  def make_entitlements
    puts 'Create entitlements'
    puts '----------------------------------------'
    Entitlement.destroy_all
    YAML.load_file(Rails.root.join('db', 'seeds', 'entitlements.yml')).each do |data|
      Entitlement.create!(name: data['name'])
    end
  end

  def make_ticket_types
    puts 'Create ticket types'
    puts '----------------------------------------'
    TicketType.destroy_all
    YAML.load_file(Rails.root.join('db', 'seeds', 'ticket_types.yml')).each do |data|
      ticket_type = TicketType.new(name: data['name'], company: data['company'], credit: data['credit'])
      data['entitlements'].each do |entitlement|
        ticket_type.entitlements << Entitlement.find_by(name: entitlement['name'])
      end
      ticket_type.save!
    end
  end

  def make_tickets
    puts 'Create tickets'
    puts '----------------------------------------'
    Ticket.destroy_all
    YAML.load_file(Rails.root.join('db', 'seeds', 'tickets.yml')).each do |data|
      ticket = Ticket.new(number: data['number'])
      ticket.ticket_type = TicketType.find_by(name: data['ticket_type'])
      ticket.save!
    end
  end

  def make_gtags
    puts 'Create GTags'
    puts '----------------------------------------'
    Gtag.destroy_all
    YAML.load_file(Rails.root.join('db', 'seeds', 'gtags.yml')).each do |data|
      gtag = Gtag.new(tag_serial_number: data['tag_serial_number'], tag_uid: data['tag_uid'])
      gtag.save!
    end
  end

end