class EventCreator
  attr_reader :event

  def initialize(params)
    @params = params
    @event = Event.none
  end

  def save
    @event = Event.new(@params)
    @event.save
    standard_credit
    default_event_parameters
    default_event_translations
  end

  private

  def default_event_parameters
    Seeder::SeedLoader.load_default_event_parameters(@event)
  end

  def default_event_translations
    YAML.load_file(Rails.root.join("db", "seeds", "default_event_translations.yml")).each do |data|
      I18n.locale = data["locale"]
      @event.update(info: data["info"],
                    disclaimer: data["disclaimer"],
                    refund_success_message: data["refund_success_message"],
                    mass_email_claim_notification: data["mass_email_claim_notification"],
                    gtag_assignation_notification: data["gtag_assignation_notification"],
                    gtag_form_disclaimer: data["gtag_form_disclaimer"],
                    gtag_name: data["gtag_name"])
    end
  end

  def standard_credit
    YAML.load_file(Rails.root.join("db", "seeds", "standard_credits.yml")).each do |data|
      preevent_item = PreeventItem.new(
        event_id: @event.id,
        name: data["name"],
        description: data["description"]
      )
      Credit.create(standard: data["standard"], preevent_item: preevent_item)
      PreeventProduct.create(
        event_id: @event.id,
        name: "Creditaker",
        online: true,
        initial_amount: 1,
        step: 1,
        min_purchasable: 1,
        max_purchasable: 20,
        price: 1
      )
    end
  end
end
