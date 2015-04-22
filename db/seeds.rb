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

