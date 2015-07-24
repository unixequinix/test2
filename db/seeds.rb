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
  'gtag' => {
    'form' => {
      'format' => 'string',
      'notation' => 'string'
    }
  },
  'refund' => {
    'epg' => {
      'fee' => 'currency',
      'minimum' => 'currency',
      'country' => 'string',
      'currency' => 'string',
      'operation_type' => 'string',
      'payment_solution' => 'string',
      'md5key' => 'string',
      'merchant_id' => 'string',
      'url' => 'string'
    },
    'bank_account' => {
      'fee' => 'currency',
      'minimum' => 'currency'
    }
  }
}

parameters.each do |category, group|
  puts "Category: #{category}"
  group.each do |group_name, param_list|
      puts " - Group: #{group_name}"
    param_list.each do |param, data_type|
      puts "   - #{param}"
      p = Parameter.new(
        category: category,
        group: group_name,
        name: param,
        data_type: data_type,
        description: '')
      begin
        p.save
      rescue
        puts 'Already exists'
      end
    end
  end
end

# Event parameters
# ------------------------------

puts "Create default values for event parameters"
puts "----------------------------------------"

EventParameter.destroy_all
Event.all.each do |event|
  YAML.load_file(Rails.root.join("db", "seeds", "default_event_parameters.yml")).each do |data|
    data['groups'].each do |group|
      group['values'].each do |value|
        parameter = Parameter.find_by(category: data['category'], group: group['name'], name: value['name'])
        event_parameter = EventParameter.new(event_id: event.id, value: value['value'], parameter_id: parameter.id)
        begin
          event_parameter.save
        rescue
          puts 'Already exists'
        end
      end
    end
  end
end

# Claim parameters
# ------------------------------

puts "Create Claim parameters"
puts "----------------------------------------"

parameters = {
  'claim' => {
    'bank_account' => {
      'iban' => 'string',
      'swift' => 'string'
    },
    'epg' => {
      'country_code' => 'string',
      'state' => 'string',
      'city' => 'string',
      'post_code' => 'string',
      'phone' => 'string',
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