class BraintreePaymentSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :environment, String
  attribute :merchant_id, String
  attribute :public_key, String
  attribute :private_key, String
  attribute :event_id, Integer

  validates_presence_of :environment
  validates_presence_of :merchant_id
  validates_presence_of :public_key
  validates_presence_of :private_key
  validates_presence_of :event_id

  def save(_params, _request)
    if valid?
      persist!
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

  def main_parameters
    attributes.keys.reject { |value| value == :event_id }
  end

  private

  def persist!
    Parameter.where(category: "payment", group: "braintree").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
