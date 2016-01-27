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
      preevent_item = build_preevent_item(data["preevent_item"])
      create_credit(data["credit"], preevent_item)
      create_preevent_product(data["preevent_product"], data["preevent_product_item"], preevent_item)
    end
  end

  private

  def build_preevent_item(preevent_item_data)
    PreeventItem.new(
      event_id: @event.id,
      name: preevent_item_data["name"],
      description: preevent_item_data["description"]
    )
  end

  def create_credit(credit_data, preevent_item)
    Credit.create(
      standard: credit_data["standard"],
      value: credit_data["value"],
      currency: credit_data["currency"],
      preevent_item: preevent_item
    )
  end

  def create_preevent_product(preevent_product_data, preevent_product_item_data, preevent_item)
    PreeventProduct.create(
      event_id: @event.id,
      preevent_item_ids: [preevent_item.id],
      preevent_product_items_attributes: [{ amount: preevent_product_item_data["amount"] }],
      name: preevent_product_data["name"],
      online: preevent_product_data["online"],
      initial_amount: preevent_product_data["initial_amount"],
      step: preevent_product_data["step"],
      min_purchasable: preevent_product_data["min_purchasable"],
      max_purchasable: preevent_product_data["max_purchasable"],
      price: preevent_product_data["price"]
    )
  end
end
