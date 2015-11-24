class StripePaymentSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, String
  attribute :email, String
  attribute :country, Integer
  attribute :bank_account, String
  attribute :routing_number, String
  attribute :currency, String
  attribute :event_id, Integer

  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :country
  validates_presence_of :bank_account
  validates_presence_of :routing_number
  validates_presence_of :currency
  validates_presence_of :event_id

  # attribute :stripe_account_id, String
  # attribute :platform_secret_key, String
  # attribute :account_secret_key, String
  # attribute :account_publishable_key, String
  # validates_presence_of :stripe_account_id
  # validates_presence_of :platform_secret_key
  # validates_presence_of :account_secret_key
  # validates_presence_of :account_publishable_key

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private
  def persist!
    Parameter.where(category: 'payment', group: 'stripe').each do |parameter|
      ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      ep.nil? ?
      EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) :
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end