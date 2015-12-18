module ParametersMacros
  def load_event_parameters
    load_parameters("event_parameters.yml")
  end

  def load_claim_parameters
    load_parameters("claim_parameters.yml")
  end

  private

  def load_parameters(file_name)
    YAML.load_file(
      Rails.root.join("db", "seeds", file_name)).each do |category|
      category["groups"].each do |group|
        group["parameters"].each do |parameter|
          p = Parameter.create!(category: category["name"],
                                group: group["name"],
                                name: parameter["name"],
                                data_type: parameter["data_type"],
                                description: "")
          begin
            p.save
          rescue
            puts "Already exists"
          end
        end
      end
    end
  end
end
