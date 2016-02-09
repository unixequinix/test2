class StripePaymentSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :email, String
  attribute :currency, String
  attribute :country, String
  # attribute :bank_account, String
  # attribute :legal_first_name, String
  # attribute :legal_last_name, String
  # attribute :legal_dob, DateTime
  # attribute :legal_type, String
  attribute :event_id, Integer

  validates_presence_of :email
  validates_presence_of :currency
  validates_presence_of :country

  def save(params, request)
    if valid?
      persist!
      AccountManager::Stripe.new.persist_parameters(params, request)
      true
    else
      false
    end
  end

  def update
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    Parameter.where(category: "payment", group: "stripe").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.value = attributes[parameter.name.to_sym] || Parameter::DATA_TYPES[parameter.data_type][:default]
      ep.save!
    end
  end
end
