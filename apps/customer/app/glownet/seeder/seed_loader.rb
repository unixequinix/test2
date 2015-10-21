class Seeder::SeedLoader
  def self.load_default_event_parameters(event)
    file = "default_event_parameters.yml"
    YAML.load_file(
      Rails.root.join("db", "seeds", file)).each do |data|
      data['groups'].each do |group|
        group['values'].each do |value|
          parameter = Parameter.find_by(
            category: data['category'],
            group: group['name'],
            name: value['name']
          )
          event_parameter = EventParameter.new(
            event_id: event.id,
            value: value['value'].to_s,
            parameter_id: parameter.id
          )
          begin
            event_parameter.save!
          rescue
            Rails.logger.warn 'Already exists'
          end
        end
      end
    end
  end

  def self.create_event_parameters
    file = "event_parameters.yml"
    YAML.load_file(
      Rails.root.join("db", "seeds", file)).each do |category|
      category['groups'].each do |group|
        group['parameters'].each do |parameter|
          p = Parameter.new(
            category: category['name'],
            group: group['name'],
            name: parameter['name'],
            data_type: parameter['data_type'],
            description: ''
          )
          begin
            p.save!
          rescue
            Rails.logger.warn 'Already exists'
          end
        end
      end
    end
  end

  def self.create_claim_parameters
    file = "claim_parameters.yml"
    YAML.load_file(Rails.root.join("db", "seeds", file)).each do |category|
      category['groups'].each do |group|
        group['parameters'].each do |parameter|
          p = Parameter.new(
            category: category['name'],
            group: group['name'],
            name: parameter['name'],
            data_type: parameter['data_type'],
            description: ''
          )
          begin
            p.save!
          rescue
            Rails.logger.warn 'Already exists'
          end
        end
      end
    end
  end

end