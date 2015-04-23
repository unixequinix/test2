# Cleanup
# ------------------------------

Admin.destroy_all
Customer.destroy_all

# Admins
# ------------------------------
puts "Create admins"
puts "----------------------------------------"

Admin.create(email: 'admin@test.com', password: 'password')

# Customers
# ------------------------------
puts "Create customers"
puts "----------------------------------------"

Customer.create(email: 'customer@test.com', password: 'password', name: 'Test', surname: 'Test Surname', confirmed_at: '2015-04-21 13:39:18.381529')

# Entitlements
# ------------------------------
puts "Create entitlements"
puts "----------------------------------------"

Entitlement.destroy_all
YAML.load_file(Rails.root.join("db", "seeds", "entitlements.yml")).each do |data|
  Entitlement.create!(name: data['name'])
end

# Ticket Types
# ------------------------------
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

# Tickets
# ------------------------------
puts "Create tickets"
puts "----------------------------------------"

Ticket.destroy_all
YAML.load_file(Rails.root.join("db", "seeds", "tickets.yml")).each do |data|
  ticket = Ticket.new(number: data['number'])
  ticket.ticket_type = TicketType.find_by(name: data['ticket_type'])
  ticket.save!
end

# Online Products
# ------------------------------
puts "Create online products"
puts "----------------------------------------"

OnlineProduct.destroy_all
YAML.load_file(Rails.root.join("db", "seeds", "online_products.yml")).each do |data|
  OnlineProduct.create!(name: data['name'], description: data['description'], amount: data['amount'])
end