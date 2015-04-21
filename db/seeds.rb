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

Customer.create(email: 'admin@test.com', password: 'password')

