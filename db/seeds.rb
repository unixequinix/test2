# Event parameters
# ------------------------------

puts "----------------------------------------"
puts "Create event parameters"
puts "----------------------------------------"

Seeder::SeedLoader.create_event_parameters

# Claim parameters
# ------------------------------

puts "Create Claim parameters"
puts "----------------------------------------"

Seeder::SeedLoader.create_claim_parameters

# Stations
# ------------------------------

puts "Create Stations"
puts "----------------------------------------"

Seeder::SeedLoader.create_stations
