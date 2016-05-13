class PaypalNvpPaymentSettingsForm < BaseSettingsForm
  attribute :user, String
  attribute :password, String
  attribute :signature, String
  attribute :merchant_id, String
  attribute :currency, String
  attribute :url, String
  attribute :autotopup, Boolean
  attribute :event_id, Integer

  validates_presence_of :user
  validates_presence_of :password
  validates_presence_of :signature
  validates_presence_of :merchant_id
  validates_presence_of :currency
  validates_presence_of :url
  validates_presence_of :event_id

  private

  def persist!
    persist_parameters(Parameter.where(category: "payment", group: "paypal_nvp"))
  end
end
