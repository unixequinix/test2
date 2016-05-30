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
      Rails.root.join("db", "seeds", file)
    ).each do |data|
      data["groups"].each do |group|
        group["values"].each do |value|
          EventParameter.find_or_create_by(event: event,
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
          Parameter.find_or_create_by(category: category["name"],
                                      group: group["name"],
                                      name: parameter["name"],
                                      data_type: parameter["data_type"],
                                      description: "")
        end
      end
    end
  end

  def self.create_stations
    YAML.load_file(Rails.root.join("db", "seeds", "stations.yml")).each do |group|
      @station_group = StationGroup.find_or_create_by(name: group["name"],
                                                      icon_slug: group["icon_slug"])
      group["types"].each do |type|
        @station_group.station_types
                      .find_or_create_by(name: type["name"],
                                         description: type["description"],
                                         environment: type["environment"])
      end
    end
  end
end
