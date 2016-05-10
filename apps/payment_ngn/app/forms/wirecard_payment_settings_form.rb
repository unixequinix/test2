class WirecardPaymentSettingsForm < BaseSettingsForm
  attribute :customer_id, String
  attribute :secret_key, String
  attribute :event_id, Integer
  attribute :environment, String

  validates_presence_of :customer_id
  validates_presence_of :secret_key
  validates_presence_of :event_id
  validates :environment, inclusion: { in: %w(demo production) }

  private

  def persist!
    persist_parameters(Parameter.where(category: "payment", group: "wirecard"))
  end
end
