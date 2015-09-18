# Event parameters
# ------------------------------

puts "Create event parameters"
puts "----------------------------------------"

YAML.load_file(Rails.root.join("db", "seeds", "event_parameters.yml")).each do |category|
  puts "Category: #{category['name']}"
  category['groups'].each do |group|
    puts " - Group: #{group['name']}"
    group['parameters'].each do |parameter|
      puts "   - #{parameter['name']}"
      p = Parameter.create!(category: category['name'], group: group['name'],
                        name: parameter['name'], data_type: parameter['data_type'], description: '')
      begin
        p.save
      rescue
        puts 'Already exists'
      end
    end
  end
end

# Claim parameters
# ------------------------------

puts "Create Claim parameters"
puts "----------------------------------------"

YAML.load_file(Rails.root.join("db", "seeds", "claim_parameters.yml")).each do |category|
  puts "Category: #{category['name']}"
  category['groups'].each do |group|
    puts " - Group: #{group['name']}"
    group['parameters'].each do |parameter|
      puts "   - #{parameter['name']}"
      p = Parameter.create!(category: category['name'], group: group['name'],
                        name: parameter['name'], data_type: parameter['data_type'], description: '')
      begin
        p.save
      rescue
        puts 'Already exists'
      end
    end
  end
end