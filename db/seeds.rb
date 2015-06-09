# Cleanup
# ------------------------------

Admin.destroy_all
Event.destroy_all

# Admins
# ------------------------------
puts "Create admins"
puts "----------------------------------------"

Admin.create(email: 'admin@test.com', password: 'password')

# Events
# ------------------------------
puts "Create events"
puts "----------------------------------------"

Event.create(name: 'Barcelona Beach Festival')


puts "Create credits"
puts "----------------------------------------"

OnlineProduct.destroy_all
Credit.destroy_all
YAML.load_file(Rails.root.join("db", "seeds", "credits.yml")).each do |data|
  credit = Credit.new(standard: data['standard'])
  credit.online_product = OnlineProduct.new(name: data['name'], description: data['description'], price: data['price'], min_purchasable: data['min_purchasable'], max_purchasable: data['max_purchasable'], initial_amount: data['initial_amount'], step: data['step'])
  credit.save!
end