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
        name: data["preevent_item"]["name"],
        description: data["preevent_item"]["description"]
      )
      Credit.create(
        standard: data["credit"]["standard"],
        value: data["credit"]["value"],
        currency: data["credit"]["currency"],
        preevent_item: preevent_item
      )
      PreeventProduct.create(
        event_id: @event.id,
        preevent_item_ids: [preevent_item.id],
        preevent_product_items_attributes: [{ amount: data["preevent_product_item"]["amount"] }],
        name: data["preevent_product"]["name"],
        online: data["preevent_product"]["online"],
        initial_amount: data["preevent_product"]["initial_amount"],
        step: data["preevent_product"]["step"],
        min_purchasable: data["preevent_product"]["min_purchasable"],
        max_purchasable: data["preevent_product"]["max_purchasable"],
        price: data["preevent_product"]["price"]
      )
    end
  end
end
