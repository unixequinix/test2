class IdealPaymentSettingsForm < BaseSettingsForm
  attribute :customer_id, String
  attribute :secret_key, String

  validates_presence_of :customer_id
  validates_presence_of :secret_key

  private

  def persist!
    persist_parameters(Parameter.where(category: "payment", group: "ideal"))
  end
end
