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

Event.destroy_all
YAML.load_file(Rails.root.join("db", "seeds", "events.yml")).each do |data|
  event = Event.new(name: data['name'], location: data['location'], start_date: data['start_date'], end_date: data['end_date'], description: data['description'], support_email: data['support_email'])
  event.save!
end

puts "Create credits"
puts "----------------------------------------"

OnlineProduct.destroy_all
Credit.destroy_all
YAML.load_file(Rails.root.join("db", "seeds", "credits.yml")).each do |data|
  credit = Credit.new(standard: data['standard'])
  credit.online_product = OnlineProduct.new(name: data['name'], description: data['description'], price: data['price'], min_purchasable: data['min_purchasable'], max_purchasable: data['max_purchasable'], initial_amount: data['initial_amount'], step: data['step'])
  credit.save!
end


# Event parameters
# ------------------------------

puts "Create event parameters"
puts "----------------------------------------"

Parameter.destroy_all
parameters = {
  'form' => {
    'gtag' => {
      'format' => 'string',
      'notation' => 'string'
    }
  },
  'refund' => {
    'epg' => {
      'format' => 'string',
      'notation' => 'string'
    },
  }
}

parameters.each do |category, group|
  puts "Category: #{category}"
  group.each do |group_name, param_list|
      puts " - Group: #{group_name}"
    param_list.each do |param, data_type|
      puts "   - #{param}"
      p = Parameter.create!(category: category, group: group_name,
                          name: param, data_type: data_type, description: '')
    end
  end
end

# Claim parameters
# ------------------------------

puts "Create Claim parameters"
puts "----------------------------------------"

Parameter.destroy_all
parameters = {
  'claim' => {
    'bank_account' => {
      'iban' => 'string',
      'swift' => 'string'
    },
    'epg' => {
      'state' => 'string',
      'city' => 'string',
      'post_code' => 'string',
      'telephone' => 'string',
      'address' => 'string'
    }
  }
}

parameters.each do |category, group|
  puts "Category: #{category}"
  group.each do |group_name, param_list|
      puts " - Group: #{group_name}"
    param_list.each do |param, data_type|
      puts "   - #{param}"
      p = Parameter.create!(category: category, group: group_name,
                          name: param, data_type: data_type, description: '')
    end
  end
end