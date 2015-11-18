class StripePaymentSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, String
  attribute :secret_key, String
  attribute :publishable_key, String
  attribute :event_id, Integer

  validates_presence_of :name
  validates_presence_of :secret_key
  validates_presence_of :publishable_key
  validates_presence_of :event_id

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
      ep.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end