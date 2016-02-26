class Seeder::SeedLoader
  def self.load_param(event, atts)
    params = Parameter.where(atts)
    params = FactoryGirl.create(:parameter, atts) if params.empty?
    params.each do |p|
      value = Parameter.default_value_for(p.data_type)
      FactoryGirl.create(:event_parameter, event: event, parameter: p, value: value)
    end
  end

  def self.load_default_event_parameters(event)
    file = "default_event_parameters.yml"
    YAML.load_file(
      Rails.root.join("db", "seeds", file)).each do |data|
      data["groups"].each do |group|
        group["values"].each do |value|
          try_to_save EventParameter.new(event: event,
                                         value: value["value"].to_s,
                                         parameter: Parameter.find_by(category: data["category"],
                                                                      group: group["name"],
                                                                      name: value["name"]))
        end
      end
    end
  end

  def self.create_event_parameters
    create_parameters "event_parameters.yml"
  end

  def self.create_claim_parameters
    create_parameters "claim_parameters.yml"
  end

  def self.create_parameters(file)
    YAML.load_file(Rails.root.join("db", "seeds", file)).each do |category|
      category["groups"].each do |group|
        group["parameters"].each do |parameter|
          try_to_save Parameter.new(category: category["name"],
                                    group: group["name"],
                                    name: parameter["name"],
                                    data_type: parameter["data_type"],
                                    description: "")
        end
      end
    end
  end

  def self.create_stations
    StationType.destroy_all
    StationGroup.destroy_all

    YAML.load_file(Rails.root.join("db", "seeds", "stations.yml")).each do |group|
      @station_group = StationGroup.create!(name: group["name"])
      group["types"].each do |type|
        @station_group.station_types.create!(name: type["name"], description: type["name"])
      end
    end
  end

  def self.try_to_save(obj)
    obj.save!
  rescue
    Rails.logger.warn "Already exists"
  end
end
