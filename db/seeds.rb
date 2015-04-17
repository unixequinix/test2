# Cleanup
# ------------------------------

Customer.destroy_all

# Admins
# ------------------------------
puts "Create customers"
puts "----------------------------------------"

Admin.create(email: 'admin@test.com', password: 'password')