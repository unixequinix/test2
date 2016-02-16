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
      create_preevent_product(data["preevent_product"],
                              data["preevent_product_item"],
                              preevent_item)
    end
  end

  private

  def build_preevent_item(preevent_item_data)
    PreeventItem.new(event_id: @event.id,
                     name: preevent_item_data["name"],
                     description: preevent_item_data["description"])
  end

  def create_credit(credit_data, preevent_item)
    Credit.create(standard: credit_data["standard"],
                  value: credit_data["value"],
                  currency: credit_data["currency"],
                  preevent_item: preevent_item)
  end

  def create_preevent_product(product_data, product_item_data, item)
    data = %w( name online initial_amount step min_purchasable max_purchasable price )
    params = data.map { |name| [name, product_data[name]] }.to_h
    params.merge!(event: @event,
                  preevent_product_items_attributes: [{ preevent_item: item,
                                                        amount: product_item_data["amount"] }])
    PreeventProduct.create(params)
  end
end
