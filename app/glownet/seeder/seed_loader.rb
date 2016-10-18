class Seeder::SeedLoader
  def self.load_param(event, atts)
    params = Parameter.where(atts)
    params = FactoryGirl.create(:parameter, atts) if params.empty?
    params.each do |param|
      value = Parameter.default_value_for(param.data_type)
      # TODO: Why are we using FactoryGirl?
      FactoryGirl.create(:event_parameter, event: event, parameter: param, value: value)
    end
  end

  def self.load_default_event_parameters(event)
    YAML.load_file(Rails.root.join("db", "seeds", "default_event_parameters.yml")).each do |data|
      data["groups"].each do |group|
        group["values"].each do |value|
          param = Parameter.find_by(category: data["category"], group: group["name"], name: value["name"])
          EventParameter.find_or_create_by(event: event, value: value["value"].to_s, parameter: param)
        end
      end
    end
  end

  def self.load_default_event_translations(event)
    YAML.load_file(Rails.root.join("db", "seeds", "default_event_translations.yml")).each do |data|
      I18n.locale = data["locale"]
      event.update(info: data["info"],
                   disclaimer: data["disclaimer"],
                   privacy_policy: data["privacy_policy"],
                   terms_of_use: data["terms_of_use"],
                   refund_success_message: data["refund_success_message"],
                   mass_email_claim_notification: data["mass_email_claim_notification"],
                   gtag_assignation_notification: data["gtag_assignation_notification"],
                   gtag_form_disclaimer: data["gtag_form_disclaimer"],
                   gtag_name: data["gtag_name"])
    end
  end

  def self.create_event_parameters
    create_parameters "event_parameters.yml"
  end

  def self.create_claim_parameters
    create_parameters "claim_parameters.yml"
  end

  def self.create_parameters(file)
    YAML.load_file(Rails.root.join("db", "seeds", file)).each do |cat|
      cat["groups"].each do |group|
        group["parameters"].each do |param|
          atts = { category: cat["name"], group: group["name"], name: param["name"], data_type: param["data_type"] }
          Parameter.find_or_create_by(atts)
        end
      end
    end
  end
end
