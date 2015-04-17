# Cleanup
# ------------------------------

Customer.destroy_all

# Admins
# ------------------------------
puts "Create customers"
puts "----------------------------------------"

Customer.create(email: 'admin@test.com', password: 'password')