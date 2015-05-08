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