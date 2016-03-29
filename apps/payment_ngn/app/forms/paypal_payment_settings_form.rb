class PaypalPaymentSettingsForm < BaseSettingsForm
  attribute :environment, String
  attribute :merchant_id, String
  attribute :public_key, String
  attribute :private_key, String
  attribute :autotopup, Boolean
  attribute :event_id, Integer

  validates_presence_of :environment
  validates_presence_of :merchant_id
  validates_presence_of :public_key
  validates_presence_of :private_key
  validates_presence_of :event_id

  private

  def persist!
    persist_parameters(Parameter.where(category: "payment", group: "braintree"))
  end
end
