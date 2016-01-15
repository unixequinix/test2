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
    YAML.load_file(Rails.root.join('db', 'seeds', 'default_event_translations.yml')).each do |data|
      I18n.locale = data['locale']
      @event.update(info: data['info'],
                    disclaimer: data['disclaimer'],
                    refund_success_message: data['refund_success_message'],
                    mass_email_claim_notification: data['mass_email_claim_notification'],
                    gtag_assignation_notification: data['gtag_assignation_notification'],
                    gtag_form_disclaimer: data['gtag_form_disclaimer'],
                    gtag_name: data['gtag_name'])
    end
  end

  def standard_credit
    YAML.load_file(Rails.root.join('db', 'seeds', 'standard_credits.yml')).each do |data|
      credit = Credit.new(standard: data['standard'])
      credit.online_product = OnlineProduct.new(event_id: @event.id, name: data['name'],
                                                description: data['description'],
                                                price: data['price'],
                                                min_purchasable: data['min_purchasable'],
                                                max_purchasable: data['max_purchasable'],
                                                initial_amount: data['initial_amount'],
                                                step: data['step'])
      credit.save!
    end
  end
end
