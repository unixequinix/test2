class StripePaymentSettingsForm < BaseSettingsForm
  attribute :email, String
  attribute :currency, String
  attribute :country, String
  attribute :bank_account, String
  attribute :legal_first_name, String
  attribute :legal_last_name, String
  attribute :legal_dob, DateTime
  attribute :legal_type, String
  attribute :city, String
  attribute :line1, String
  attribute :postal_code, String
  attribute :tos_acceptance_date, String
  attribute :tos_acceptance_ip, String
  attribute :event_id, Integer
  attribute :application_fee, Integer
  attribute :stripe_account_id, String
  attribute :account_secret_key, String
  attribute :account_publishable_key, String


  validates_presence_of :email
  validates_presence_of :currency
  validates_presence_of :country
  validates_presence_of :application_fee

  def save(params, request)
    if valid?
      AccountManager::Stripe.new.update_parameters(attributes, request)
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
      value = attributes[parameter.name.to_sym] || Parameter::DATA_TYPES[parameter.data_type][:default]
      ep.update(value: value)
    end
  end
end
