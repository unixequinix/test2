class StripePaymentActivationForm < BaseSettingsForm
  attribute :email, String
  attribute :currency, String
  attribute :country, String
  attribute :event_id, Integer
  attribute :application_fee, Integer

  validates_presence_of :email
  validates_presence_of :currency
  validates_presence_of :country
  validates_presence_of :application_fee

  def save(params, request)
    return unless valid?
    persist!

    begin
      Payments::Stripe::AccountManager.new.persist_parameters(params, request)
    rescue Stripe::InvalidRequestError => e
      err = e.json_body[:error]
      errors.add(:request, ": #{err[:message]}") && return
    end

    true
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
